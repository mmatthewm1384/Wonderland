#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def run_check(name: str, cmd: list[str]) -> int:
    print(f"== {name} ==")
    proc = subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    print(proc.stdout.rstrip())
    if proc.returncode == 0:
        print(f"PASS {name}")
        print()
        return 0

    print(f"FAIL {name}")
    print()
    return 1


def main() -> int:
    failures = 0

    print("Wonderland Engineering Doctor")
    print()

    failures += run_check("Registry Service", ["bin/wl-registry", "verify"])
    failures += run_check("Architecture Gate", ["python3", "01-Platform/architecture/engine.py", "gate", "--root", str(ROOT)])
    failures += run_check("Builder Ownership", ["bin/wl-builder-ownership"])
    failures += run_check("Unified Engineering Gate", ["bin/wl-engineering-gate"])

    if failures:
        print(f"FAIL engineering doctor: {failures} failure(s)")
        print("RESULT FAIL")
        return 1

    print("PASS engineering doctor")
    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
