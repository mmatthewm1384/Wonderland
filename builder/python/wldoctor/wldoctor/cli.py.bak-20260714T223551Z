from __future__ import annotations

import argparse
import json
import os
import subprocess
from pathlib import Path

from .engine import DoctorEngine


def repository_root() -> Path:
    configured = os.environ.get("WL_ROOT")

    if configured:
        return Path(configured).resolve()

    result = subprocess.run(
        [
            "git",
            "rev-parse",
            "--show-toplevel",
        ],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )

    return Path(result.stdout.strip()).resolve()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="wl doctor",
    )

    parser.add_argument(
        "--json",
        action="store_true",
    )

    args = parser.parse_args(argv)

    report = DoctorEngine(
        repository_root()
    ).doctor()

    if args.json:
        print(
            json.dumps(
                report,
                indent=2,
                sort_keys=True,
            )
        )
    else:
        print(
            "Wonderland Doctor"
        )
        print(
            f"status={report['status']}"
        )

        for name, system in report["systems"].items():
            print(
                f"{name}={system['status']}"
            )

    return (
        0
        if report["status"] == "PASS"
        else 1
    )


if __name__ == "__main__":
    raise SystemExit(main())
