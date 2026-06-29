#!/usr/bin/env python3
import argparse
import json
import os
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(os.environ.get("WONDERLAND_ROOT", Path.home() / "Wonderland")).resolve()
FP = ROOT / "vault/05-Registry/chaos/fingerprint.json"
LEASE = ROOT / "vault/05-Registry/chaos/lease.json"

def parse_time(value):
    return datetime.fromisoformat(value.replace("Z", "+00:00"))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", default=None)
    parser.add_argument("--scope", default="chaos.menubar")
    args = parser.parse_args()

    if not FP.exists():
        print(f"FAIL fingerprint missing: {FP}")
        return 1

    if not LEASE.exists():
        print(f"FAIL lease missing: {LEASE}")
        return 1

    fp = json.loads(FP.read_text())
    lease = json.loads(LEASE.read_text())

    if lease.get("schema") != "wonderland.chaos.lease.v1":
        print("FAIL lease schema invalid")
        return 1

    if lease.get("status") != "active":
        print("FAIL lease inactive")
        return 1

    if lease.get("scope") != args.scope:
        print("FAIL lease scope mismatch")
        print(f"expected={args.scope}")
        print(f"actual={lease.get('scope')}")
        return 1

    if args.mode and lease.get("mode") != args.mode:
        print("FAIL lease mode mismatch")
        print(f"expected={args.mode}")
        print(f"actual={lease.get('mode')}")
        return 1

    if lease.get("fingerprint_id") != fp.get("fingerprint_id"):
        print("FAIL lease fingerprint mismatch")
        return 1

    expires = parse_time(lease["expires_at"])
    now = datetime.now(timezone.utc)

    if now >= expires:
        print("FAIL lease expired")
        print(f"expired_at={lease['expires_at']}")
        return 1

    print(f"PASS lease verified: {lease['mode']} {lease['fingerprint_short']}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
