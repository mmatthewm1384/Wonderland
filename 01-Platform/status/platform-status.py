#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


CHECKS = [
    ("registry", ["bin/wl-registry", "verify"]),
    ("architecture", ["python3", "01-Platform/architecture/engine.py", "gate", "--root", str(ROOT)]),
    ("builder", ["bin/wl-builder-ownership"]),
    ("manifest_index", ["bin/wl-manifest-index"]),
    ("engineering_gate", ["bin/wl-engineering-gate"]),
]


def run(cmd: list[str]) -> dict[str, object]:
    proc = subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return {
        "exit_code": proc.returncode,
        "result": "PASS" if proc.returncode == 0 else "FAIL",
        "output": proc.stdout,
    }


def manifest_count() -> int:
    idx = ROOT / "05-Vault/generated/indexes/manifest-index.json"
    if not idx.exists():
        return 0
    try:
        return int(json.loads(idx.read_text()).get("manifest_count", 0))
    except Exception:
        return 0


def main() -> int:
    results = {}
    failures = 0

    for name, cmd in CHECKS:
        result = run(cmd)
        results[name] = result
        if result["exit_code"] != 0:
            failures += 1

    print("Wonderland Platform Status")
    print()
    for name, result in results.items():
        print(f"{name}: {result['result']}")

    print()
    print(f"manifests: {manifest_count()}")

    print()
    if failures:
        print(f"FAIL platform status: {failures} failure(s)")
        print("RESULT FAIL")
        return 1

    print("PASS platform status")
    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
