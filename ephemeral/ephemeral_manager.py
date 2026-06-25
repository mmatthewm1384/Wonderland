#!/usr/bin/env python3
import pathlib
import sys
from datetime import datetime, timezone

ROOT = pathlib.Path.home() / "Wonderland"
CHAOS = ROOT / "vault" / "chaos"
LOG = CHAOS / "ephemeral-manager.log"

def main():
    CHAOS.mkdir(parents=True, exist_ok=True)
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    msg = f"{datetime.now(timezone.utc).isoformat()} ephemeral_manager {cmd}: ok"
    LOG.open("a", encoding="utf-8").write(msg + "\n")
    print(msg)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
