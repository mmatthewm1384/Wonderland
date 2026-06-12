#!/usr/bin/env python3
import os
import sys
import json

REGISTRY_PATH = os.path.expanduser("~/Wonderland/Wonderland-v4/configs/wl-registry.json")

def verify_environment():
    if not os.path.exists(REGISTRY_PATH):
        print(f"CRITICAL: System profile missing at {REGISTRY_PATH}", file=sys.stderr)
        return False
        
    with open(REGISTRY_PATH, "r") as f:
        data = json.load(f)
        
    if data.get("system_mode") != "single_user":
        print("ERROR: Multi-tenant execution anomaly detected!", file=sys.stderr)
        return False
        
    current_user = os.getlogin() if hasattr(os, "getlogin") else os.environ.get("USER")
    print(f"[IDENTITY] Confirmed single-user execution lock for profile: {current_user}")
    return True

if __name__ == "__main__":
    sys.exit(0 if verify_environment() else 1)
