#!/usr/bin/env python3
import hashlib
import json
import os
import platform
import plistlib
import subprocess
import sys
from pathlib import Path
from datetime import datetime, timezone

ROOT = Path(os.environ.get("WONDERLAND_ROOT", Path.home() / "Wonderland")).resolve()
REGISTRY = ROOT / "vault/05-Registry/chaos/fingerprint.json"

def sh(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""

def machine_uuid():
    raw = sh(["ioreg", "-rd1", "-c", "IOPlatformExpertDevice"])
    for line in raw.splitlines():
        if "IOPlatformUUID" in line:
            return line.split("=")[-1].strip().strip('"')
    return sh(["hostname"]) or "unknown-machine"

def canonical_hash(payload):
    data = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(data).hexdigest()

def main():
    inputs = {
        "schema": "wonderland.fingerprint.v1",
        "machine_uuid": machine_uuid(),
        "wonderland_root": str(ROOT),
        "operator": os.environ.get("USER", "unknown"),
        "hostname": sh(["hostname"]) or platform.node(),
        "platform": platform.platform(),
        "authority_scope": "chaos.menubar",
    }

    fingerprint_id = canonical_hash(inputs)

    doc = {
        "schema": "wonderland.chaos.fingerprint.v1",
        "fingerprint_id": fingerprint_id,
        "fingerprint_short": fingerprint_id[:12],
        "inputs": inputs,
        "generated_at": datetime.now(timezone.utc).isoformat(),
    }

    REGISTRY.parent.mkdir(parents=True, exist_ok=True)
    tmp = REGISTRY.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n")
    tmp.replace(REGISTRY)

    print(f"PASS fingerprint generated")
    print(f"fingerprint_id={fingerprint_id}")
    print(f"fingerprint_short={fingerprint_id[:12]}")
    print(f"path={REGISTRY}")

if __name__ == "__main__":
    main()
