#!/usr/bin/env python3
from __future__ import annotations

import subprocess
from pathlib import Path


ROOT = Path.home() / "Wonderland"


def main() -> int:
    archive = ROOT / "runtime/backups/wonderland-control-plane-latest.tar.gz"

    if not archive.exists():
        print(f"FAIL missing backup: {archive}")
        return 1

    p = subprocess.run(
        ["tar", "-tzf", str(archive)],
        text=True,
        capture_output=True,
        check=False,
    )

    if p.returncode != 0:
        print("FAIL backup unreadable")
        print(p.stderr)
        return 1

    required = [
        "vault/05-Registry",
        "vault/09-Timeline",
        "runtime/events",
        "controller/wl_controller",
        "schemas",
    ]

    missing = [item for item in required if item not in p.stdout]

    if missing:
        print("RESULT FAIL")
        for item in missing:
            print(f"FAIL missing {item}")
        return 1

    print("RESULT PASS")
    print(f"PASS backup {archive}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
