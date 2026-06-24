#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
EPH="$ROOT/ephemeral"
SCRIPTS="$EPH/scripts"

mkdir -p "$SCRIPTS"

cat > "$SCRIPTS/venv_bootstrap_guard.py" <<'PY'
#!/usr/bin/env python3
"""
Wonderland venv-bootstrap-guard

Canonical Python isolation guard for child ephemerals.

Policy:
- Core manager remains pure stdlib.
- uv is preferred when present.
- stdlib venv + pip is mandatory fallback.
- No global Python packages are used.
- Repair is deterministic.
"""

from __future__ import annotations

import argparse
import importlib
import json
import os
import shutil
import subprocess
import sys
import venv
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable, Optional


MARKER = "._installed"
AUDIT = ".venv-bootstrap-guard.audit.jsonl"


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def log(msg: str) -> None:
    print(f"[INFO] {msg}", flush=True)


def warn(msg: str) -> None:
    print(f"[WARN] {msg}", flush=True)


def fail(msg: str, code: int = 1) -> None:
    print(f"[FAIL] {msg}", file=sys.stderr, flush=True)
    raise SystemExit(code)


def run(cmd: list[str], cwd: Optional[Path] = None, env: Optional[dict[str, str]] = None) -> None:
    log("Running: " + " ".join(cmd))
    subprocess.run(cmd, cwd=str(cwd) if cwd else None, env=env, check=True)


def audit(project_dir: Path, event: str, payload: dict) -> None:
    record = {
        "recorded_at": now(),
        "event": event,
        "payload": payload,
    }
    with (project_dir / AUDIT).open("a", encoding="utf-8") as f:
        f.write(json.dumps(record, sort_keys=True) + "\n")


def split_imports(value: Optional[Iterable[str] | str]) -> list[str]:
    if value is None:
        return []
    if isinstance(value, str):
        return [x.strip() for x in value.split(",") if x.strip()]
    out: list[str] = []
    for item in value:
        out.extend(split_imports(item))
    return out


def python_bin(venv_dir: Path) -> Path:
    if os.name == "nt":
        return venv_dir / "Scripts" / "python.exe"
    return venv_dir / "bin" / "python"


def pip_bin(venv_dir: Path) -> Path:
    if os.name == "nt":
        return venv_dir / "Scripts" / "pip.exe"
    return venv_dir / "bin" / "pip"


def marker_path(venv_dir: Path) -> Path:
    return venv_dir / MARKER


def is_healthy(venv_dir: Path) -> bool:
    py = python_bin(venv_dir)
    marker = marker_path(venv_dir)
    return venv_dir.exists() and py.exists() and marker.exists()


def backend_available(preferred_backend: str) -> str:
    if preferred_backend == "stdlib":
        return "stdlib"
    if preferred_backend == "uv" and shutil.which("uv"):
        return "uv"
    if preferred_backend == "auto" and shutil.which("uv"):
        return "uv"
    return "stdlib"


def create_with_uv(project_dir: Path, venv_dir: Path, python: Optional[str]) -> None:
    cmd = ["uv", "venv", str(venv_dir)]
    if python:
        cmd.extend(["--python", python])
    run(cmd, cwd=project_dir)


def create_with_stdlib(venv_dir: Path) -> None:
    log(f"Creating venv at {venv_dir}")
    builder = venv.EnvBuilder(with_pip=True, clear=False, upgrade_deps=False)
    builder.create(str(venv_dir))
    log("Venv created successfully")


def install_requirements_uv(project_dir: Path, venv_dir: Path, requirements: Path, sync: bool) -> None:
    env = os.environ.copy()
    env["VIRTUAL_ENV"] = str(venv_dir)
    env["PATH"] = str(venv_dir / "bin") + os.pathsep + env.get("PATH", "")
    if sync:
        run(["uv", "pip", "sync", str(requirements), "--python", str(python_bin(venv_dir))], cwd=project_dir, env=env)
    else:
        run(["uv", "pip", "install", "-r", str(requirements), "--python", str(python_bin(venv_dir))], cwd=project_dir, env=env)


def install_requirements_stdlib(venv_dir: Path, requirements: Path) -> None:
    run([str(python_bin(venv_dir)), "-m", "pip", "install", "--upgrade", "pip"])
    run([str(pip_bin(venv_dir)), "install", "-r", str(requirements)])


def validate_imports_with_python(py: Path, imports: list[str]) -> None:
    if not imports:
        return
    code = "import importlib,sys\nfor m in sys.argv[1:]: importlib.import_module(m)\n"
    run([str(py), "-c", code, *imports])
    log("All imports validated successfully")


def write_marker(venv_dir: Path, backend: str, requirements: Optional[Path], imports: list[str]) -> None:
    payload = {
        "installed_at": now(),
        "backend": backend,
        "python": str(python_bin(venv_dir)),
        "requirements": str(requirements) if requirements else None,
        "validate_imports": imports,
    }
    marker_path(venv_dir).write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")


def ensure(
    project_dir: Path | str,
    requirements: Path | str | None = None,
    validate_imports: Optional[Iterable[str] | str] = None,
    venv_name: str = ".venv",
    repair_requested: bool = False,
    backend: str = "auto",
    python: Optional[str] = None,
    sync: bool = False,
) -> Path:
    project_dir = Path(project_dir).expanduser().resolve()
    project_dir.mkdir(parents=True, exist_ok=True)

    venv_dir = project_dir / venv_name
    req = Path(requirements).expanduser().resolve() if requirements else None
    imports = split_imports(validate_imports)
    selected_backend = backend_available(backend)

    if repair_requested and venv_dir.exists():
        warn(f"Repair requested; removing {venv_dir}")
        shutil.rmtree(venv_dir)

    if is_healthy(venv_dir):
        py = python_bin(venv_dir)
        validate_imports_with_python(py, imports)
        audit(project_dir, "ensure-reused", {"venv": str(venv_dir), "backend": selected_backend})
        log(f"Venv ready. Python: {py}")
        return py

    if venv_dir.exists():
        warn(f"Venv exists but is unhealthy; removing {venv_dir}")
        shutil.rmtree(venv_dir)

    if selected_backend == "uv":
        create_with_uv(project_dir, venv_dir, python)
    else:
        create_with_stdlib(venv_dir)

    if req and req.exists():
        if selected_backend == "uv":
            install_requirements_uv(project_dir, venv_dir, req, sync=sync)
        else:
            install_requirements_stdlib(venv_dir, req)
    elif req:
        fail(f"Requirements file not found: {req}")

    py = python_bin(venv_dir)
    validate_imports_with_python(py, imports)
    write_marker(venv_dir, selected_backend, req, imports)
    audit(project_dir, "ensure-created", {"venv": str(venv_dir), "backend": selected_backend})
    log(f"Venv ready. Python: {py}")
    return py


def repair(**kwargs) -> Path:
    kwargs["repair_requested"] = True
    return ensure(**kwargs)


def run_under_venv(
    run_script: Path | str,
    project_dir: Path | str,
    requirements: Path | str | None = None,
    validate_imports: Optional[Iterable[str] | str] = None,
    venv_name: str = ".venv",
    backend: str = "auto",
    script_args: Optional[list[str]] = None,
) -> None:
    py = ensure(
        project_dir=project_dir,
        requirements=requirements,
        validate_imports=validate_imports,
        venv_name=venv_name,
        backend=backend,
    )
    script = Path(run_script).expanduser().resolve()
    if not script.exists():
        fail(f"Run script not found: {script}")
    args = [str(py), str(script), *(script_args or [])]
    log("Exec under venv: " + " ".join(args))
    os.execv(str(py), args)


def cli() -> None:
    parser = argparse.ArgumentParser(description="Wonderland venv-bootstrap-guard")
    parser.add_argument("--project-dir", default=".", help="Project directory owning the local venv")
    parser.add_argument("--requirements", default=None, help="requirements.txt path")
    parser.add_argument("--validate-imports", default="", help="Comma-separated imports to validate")
    parser.add_argument("--venv-name", default=".venv", help="Venv directory name")
    parser.add_argument("--repair", action="store_true", help="Force recreate venv")
    parser.add_argument("--backend", choices=["auto", "uv", "stdlib"], default="auto", help="Backend preference")
    parser.add_argument("--python", default=None, help="Python version/path for uv backend")
    parser.add_argument("--sync", action="store_true", help="Use uv pip sync instead of install when uv is active")
    parser.add_argument("--run-script", default=None, help="Script to execute under guarded venv")
    parser.add_argument("script_args", nargs=argparse.REMAINDER)

    args = parser.parse_args()

    project_dir = Path(args.project_dir)
    requirements = Path(args.requirements) if args.requirements else None

    if args.run_script:
        run_under_venv(
            run_script=args.run_script,
            project_dir=project_dir,
            requirements=requirements,
            validate_imports=args.validate_imports,
            venv_name=args.venv_name,
            backend=args.backend,
            script_args=args.script_args,
        )
        return

    ensure(
        project_dir=project_dir,
        requirements=requirements,
        validate_imports=args.validate_imports,
        venv_name=args.venv_name,
        repair_requested=args.repair,
        backend=args.backend,
        python=args.python,
        sync=args.sync,
    )


if __name__ == "__main__":
    cli()
PY

cat > "$SCRIPTS/venv-bootstrap-guard.py" <<'PY'
#!/usr/bin/env python3
from venv_bootstrap_guard import cli

if __name__ == "__main__":
    cli()
PY

chmod +x "$SCRIPTS/venv_bootstrap_guard.py" "$SCRIPTS/venv-bootstrap-guard.py"

echo "Installed:"
echo "  $SCRIPTS/venv_bootstrap_guard.py"
echo "  $SCRIPTS/venv-bootstrap-guard.py"
