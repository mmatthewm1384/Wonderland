#!/usr/bin/env python3
import hashlib
import json
import os
import platform
import subprocess
import sys
from pathlib import Path

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
    if not REGISTRY.exists():
        print(f"FAIL fingerprint missing: {REGISTRY}")
        return 1

    doc = json.loads(REGISTRY.read_text())
    expected_inputs = {
        "schema": "wonderland.fingerprint.v1",
        "machine_uuid": machine_uuid(),
        "wonderland_root": str(ROOT),
        "operator": os.environ.get("USER", "unknown"),
        "hostname": sh(["hostname"]) or platform.node(),
        "platform": platform.platform(),
        "authority_scope": "chaos.menubar",
    }

    expected = canonical_hash(expected_inputs)
    actual = doc.get("fingerprint_id")

    if actual != expected:
        print("FAIL fingerprint mismatch")
        print(f"expected={expected}")
        print(f"actual={actual}")
        return 1

    print(f"PASS fingerprint verified: {actual[:12]}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
