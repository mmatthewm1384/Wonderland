#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
from typing import Any


def root() -> Path:
    return Path(
        os.environ.get("WONDERLAND_ROOT")
        or os.environ.get("WL_HOME")
        or Path.cwd()
    ).resolve()


def load(path: Path) -> dict[str, Any] | None:
    if not path.exists():
        return None
    return json.loads(path.read_text())


def build_report() -> dict[str, Any]:
    r = root()
    startup_path = r / "state/runtime/startup.json"
    verify_path = r / "state/runtime/verify.json"

    startup = load(startup_path)
    verify = load(verify_path)

    return {
        "schema": "wonderland.runtime.report.v1",
        "root": str(r),
        "startup": {
            "path": str(startup_path),
            "present": startup is not None,
            "data": startup,
        },
        "verify": {
            "path": str(verify_path),
            "present": verify is not None,
            "data": verify,
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="wl runtime report",
        description="Summarize Wonderland runtime state.",
    )
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    report = build_report()

    if args.json:
        print(json.dumps(report, indent=2))
        return 0

    startup = report["startup"]["data"]
    verify = report["verify"]["data"]

    print("Wonderland Runtime Report")
    print()

    if startup:
        print(f"Startup: {startup.get('status', 'unknown')}")
        print(f"Mode:    {startup.get('mode', 'unknown')}")
        print(f"Theme:   {startup.get('theme', 'unknown')}")
        print(f"Anim:    {startup.get('animation', 'unknown')}")
        print(f"Time:    {startup.get('elapsed_ms', 'unknown')} ms")
    else:
        print("Startup: missing")

    print()

    if verify:
        print(f"Verify:  {verify.get('status', 'unknown')}")
        print(f"Report:  {report['verify']['path']}")
    else:
        print("Verify:  missing")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
