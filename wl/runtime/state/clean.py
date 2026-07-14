#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
from pathlib import Path


GENERATED_FILES = [
    "state/runtime/startup.json",
    "state/runtime/verify.json",
]


def root() -> Path:
    return Path(
        os.environ.get("WONDERLAND_ROOT")
        or os.environ.get("WL_HOME")
        or Path.cwd()
    ).resolve()


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="wl runtime clean",
        description="Remove generated Wonderland runtime state files.",
    )
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    r = root()

    for rel in GENERATED_FILES:
        path = r / rel
        if path.exists():
            if args.dry_run:
                print(f"WOULD REMOVE: {path}")
            else:
                path.unlink()
                print(f"REMOVED: {path}")
        else:
            print(f"SKIP: {path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
