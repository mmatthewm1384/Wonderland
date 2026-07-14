from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import os


@dataclass(frozen=True)
class RuntimeCheck:
    name: str
    status: str
    detail: str
    required: bool = True


def root() -> Path:
    return Path(
        os.environ.get("WONDERLAND_ROOT")
        or os.environ.get("WL_HOME")
        or Path.cwd()
    ).resolve()


def exists_check(name: str, path: Path, *, required: bool = True) -> RuntimeCheck:
    if path.exists():
        return RuntimeCheck(name, "pass", str(path), required)
    status = "fail" if required else "warn"
    return RuntimeCheck(name, status, f"missing: {path}", required)


def run_checks() -> list[RuntimeCheck]:
    r = root()
    return [
        exists_check("Runtime", r / "wl/runtime/startup.py"),
        exists_check("Controller", r / "bin/wl"),
        exists_check("Runtime Design Library", r / "design/runtime"),
        exists_check("Vault", r / "vault", required=False),
        exists_check("Registry", r / "registry", required=False),
        exists_check("Services", r / "services", required=False),
        exists_check("Scheduler", r / "scheduler", required=False),
    ]


def failed_required(checks: list[RuntimeCheck]) -> bool:
    return any(c.required and c.status == "fail" for c in checks)


def as_status(checks: list[RuntimeCheck]) -> list[dict[str, object]]:
    return [
        {
            "name": c.name,
            "status": c.status,
            "detail": c.detail,
            "required": c.required,
        }
        for c in checks
    ]
