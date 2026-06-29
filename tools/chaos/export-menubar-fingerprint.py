#!/usr/bin/env python3
import json
import os
from pathlib import Path

ROOT = Path(os.environ.get("WONDERLAND_ROOT", Path.home() / "Wonderland")).resolve()
SRC = ROOT / "vault/05-Registry/chaos/fingerprint.json"
DST = ROOT / "vault/chaos/menubar-fingerprint.json"

def main():
    if not SRC.exists():
        print(f"FAIL fingerprint registry missing: {SRC}")
        return 1

    doc = json.loads(SRC.read_text())
    out = {
        "fingerprint_id": doc["fingerprint_id"],
        "fingerprint_short": doc["fingerprint_short"],
        "scope": "chaos.menubar",
        "status": "active"
    }

    DST.parent.mkdir(parents=True, exist_ok=True)
    tmp = DST.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(out, indent=2, sort_keys=True) + "\n")
    tmp.replace(DST)

    print(f"PASS menubar fingerprint exported: {out['fingerprint_short']}")
    print(f"path={DST}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
