#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys

from wl.runtime.diagnostics.checks import as_status, failed_required, run_checks


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="wl runtime doctor",
        description="Check Wonderland runtime health.",
    )
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    checks = run_checks()

    if args.json:
        print(json.dumps({
            "schema": "wonderland.runtime.doctor.v1",
            "status": "fail" if failed_required(checks) else "pass",
            "checks": as_status(checks),
        }, indent=2))
        return 1 if failed_required(checks) else 0

    print("Wonderland Runtime Doctor")
    print()

    for check in checks:
        label = {
            "pass": "PASS",
            "warn": "WARN",
            "fail": "FAIL",
        }.get(check.status, check.status.upper())

        stream = sys.stderr if check.status == "fail" else sys.stdout
        print(f"{label}: {check.name} - {check.detail}", file=stream)

    return 1 if failed_required(checks) else 0


if __name__ == "__main__":
    raise SystemExit(main())
