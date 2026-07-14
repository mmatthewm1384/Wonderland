#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
RELEASE_DIR = ROOT / "05-Vault/generated/releases"


def run(cmd: list[str]) -> tuple[int, str]:
    proc = subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return proc.returncode, proc.stdout


def main() -> int:
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    release_id = f"platform-0.4-preflight-{stamp}"
    out_dir = RELEASE_DIR / release_id
    out_dir.mkdir(parents=True, exist_ok=True)

    checks: list[dict[str, object]] = []

    commands = [
        ("registry", ["bin/wl-registry", "verify"]),
        ("architecture", ["python3", "01-Platform/architecture/engine.py", "gate", "--root", str(ROOT)]),
        ("builder_ownership", ["bin/wl-builder-ownership"]),
        ("engineering_gate", ["bin/wl-engineering-gate"]),
    ]

    failures = 0

    print("Wonderland Release Preflight")
    print()

    for name, cmd in commands:
        code, output = run(cmd)
        checks.append({
            "name": name,
            "command": cmd,
            "exit_code": code,
            "result": "PASS" if code == 0 else "FAIL",
            "output": output,
        })

        print(f"== {name} ==")
        print(output.rstrip())
        print()

        if code != 0:
            failures += 1

    manifest = {
        "release_id": release_id,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "status": "PASS" if failures == 0 else "FAIL",
        "mode": "preflight",
        "destructive_changes": False,
        "checks": checks,
    }

    manifest_path = out_dir / "release-manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")

    print(f"Manifest: {manifest_path.relative_to(ROOT)}")

    if failures:
        print(f"FAIL release preflight: {failures} failure(s)")
        print("RESULT FAIL")
        return 1

    print("PASS release preflight")
    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
