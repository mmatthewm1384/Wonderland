#!/usr/bin/env python3
import argparse
import json
import os
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path


def wonderland_policy_default_ttl_minutes():
    """Return default lease TTL in minutes from operator-gate policy."""
    from pathlib import Path
    import json

    policy_path = (
        Path.home()
        / "Wonderland"
        / "security"
        / "operator-gate"
        / "policy.json"
    )

    try:
        with policy_path.open() as f:
            policy = json.load(f)
        return int(policy.get("lease_hours", 12)) * 60
    except Exception:
        return 12 * 60


ROOT = Path(os.environ.get("WONDERLAND_ROOT", Path.home() / "Wonderland")).resolve()
FP = ROOT / "vault/05-Registry/chaos/fingerprint.json"
LEASE = ROOT / "vault/05-Registry/chaos/lease.json"

def utcnow():
    return datetime.now(timezone.utc)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", default="calm")
    parser.add_argument("--scope", default="chaos.menubar")
    parser.add_argument("--ttl-minutes", type=int, default=wonderland_policy_default_ttl_minutes())
    args = parser.parse_args()

    if not FP.exists():
        print(f"FAIL fingerprint missing: {FP}")
        return 1

    fp = json.loads(FP.read_text())
    issued = utcnow()
    expires = issued + timedelta(minutes=args.ttl_minutes)

    lease = {
        "schema": "wonderland.chaos.lease.v1",
        "lease_id": str(uuid.uuid4()),
        "operator": os.environ.get("USER", "unknown"),
        "scope": args.scope,
        "mode": args.mode,
        "issued_at": issued.isoformat(),
        "expires_at": expires.isoformat(),
        "fingerprint_id": fp["fingerprint_id"],
        "fingerprint_short": fp["fingerprint_short"],
        "status": "active"
    }

    LEASE.parent.mkdir(parents=True, exist_ok=True)
    tmp = LEASE.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(lease, indent=2, sort_keys=True) + "\n")
    tmp.replace(LEASE)

    print(f"PASS lease created: {lease['mode']}")
    print(f"lease_id={lease['lease_id']}")
    print(f"fingerprint={lease['fingerprint_short']}")
    print(f"expires_at={lease['expires_at']}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
