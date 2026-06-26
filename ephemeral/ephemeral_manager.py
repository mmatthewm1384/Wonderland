#!/usr/bin/env python3
import sys
from datetime import datetime, timezone
from pathlib import Path

WL_HOME = Path.home() / "Wonderland"
LOG = WL_HOME / "vault" / "chaos" / "ephemeral-manager.log"
LOG.parent.mkdir(parents=True, exist_ok=True)

def main():
    ts = datetime.now(timezone.utc).isoformat()
    args = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else "status"
    with LOG.open("a") as f:
        f.write(f"{ts} ephemeral_manager {args}: ok\n")
    print(f"ephemeral_manager {args}: ok")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
