#!/usr/bin/env python3
# core/mesh.py: Self-contained cryptographic ledger verification

import os
import sys
import json
import hashlib
import time

DB_DIR = os.path.expanduser("~/.wl-registry-v4")
DB_PATH = os.path.join(DB_DIR, "changelog.db")

def calculate_hash(prev_hash, timestamp, payload):
    block_string = f"{prev_hash}{timestamp}{json.dumps(payload)}".encode()
    return hashlib.sha256(block_string).hexdigest()

def ensure_genesis():
    os.makedirs(DB_DIR, exist_ok=True)
    if not os.path.exists(DB_PATH) or os.getsize(DB_PATH) == 0:
        genesis = {
            "index": 0,
            "prev_hash": "0" * 64,
            "timestamp": int(time.time()),
            "payload": {"event": "genesis", "version": "4.0"},
            "hash": ""
        }
        genesis["hash"] = calculate_hash(genesis["prev_hash"], genesis["timestamp"], genesis["payload"])
        with open(DB_PATH, "w") as f:
            f.write(json.dumps(genesis) + "\n")

def verify_chain():
    if not os.path.exists(DB_PATH):
        return False
    try:
        with open(DB_PATH, "r") as f:
            lines = [json.loads(line.strip()) for line in f if line.strip()]
        
        for i in range(len(lines)):
            block = lines[i]
            if i == 0:
                expected_hash = calculate_hash("0" * 64, block["timestamp"], block["payload"])
            else:
                expected_hash = calculate_hash(lines[i-1]["hash"], block["timestamp"], block["payload"])
            
            if block["hash"] != expected_hash:
                return False
        return True
    except Exception:
        return False

if __name__ == "__main__":
    ensure_genesis()
    if len(sys.argv) > 1 and sys.argv[1] == "verify":
        if verify_chain():
            sys.exit(0)
        else:
            print("Ledger chain validation failed.")
            sys.exit(1)
