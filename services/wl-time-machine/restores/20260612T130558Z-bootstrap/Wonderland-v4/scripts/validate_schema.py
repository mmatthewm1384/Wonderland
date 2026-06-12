#!/usr/bin/env python3
import os
import sys

def log_validation(rule, status, details):
    print(f"[{status.upper()}] Rule '{rule}': {details}")

def validate_config():
    print("=== WONDERLAND CONFIGURATION MATRIX VALIDATION ===")
    config_path = os.path.expanduser("~/Wonderland/Wonderland-v4/templates/microvm-boundary.toml")
    
    if not os.path.exists(config_path):
        print(f"[ERROR] Target config template missing at: {config_path}")
        sys.exit(1)
        
    failed = False
    lines = []
    with open(config_path, "r") as f:
        lines = f.readlines()

    # Parse key parameters cleanly without heavy external regex or third-party parser dependencies
    config = {}
    for line in lines:
        line = line.strip()
        if not line or line.startswith("#") or line.startswith("["):
            continue
        if "=" in line:
            k, v = line.split("=", 1)
            config[k.strip()] = v.strip()

    # Rule 1: Jailer mode enforcement
    jailer = config.get("jailer_mode")
    if jailer != "true":
        log_validation("JAILER_MODE_ENABLED", "FAIL", f"Expected 'true', found '{jailer}'")
        failed = True
    else:
        log_validation("JAILER_MODE_ENABLED", "PASS", "Jailer execution isolation active.")

    # Rule 2: Root privilege execution prevention
    uid = config.get("uid")
    gid = config.get("gid")
    if uid == "0" or gid == "0":
        log_validation("NON_ROOT_EXECUTION", "FAIL", f"Root uid/gid context detected! (uid={uid}, gid={gid})")
        failed = True
    else:
        log_validation("NON_ROOT_EXECUTION", "PASS", f"Unprivileged mapping verified (uid={uid}, gid={gid}).")

    # Rule 3: Static memory allocations range checks
    mem_str = config.get("memory_mib")
    if mem_str:
        try:
            mem = int(mem_str)
            if mem < 256 or mem > 8129:
                log_validation("MEMORY_BOUNDS", "FAIL", f"Allocation out of bounds: {mem} MiB")
                failed = True
            else:
                log_validation("MEMORY_BOUNDS", "PASS", f"Static bounds aligned: {mem} MiB")
        except ValueError:
            log_validation("MEMORY_BOUNDS", "FAIL", f"Invalid integer format for memory: '{mem_str}'")
            failed = True
    else:
        log_validation("MEMORY_BOUNDS", "FAIL", "Memory attribute missing from definition.")
        failed = True

    if failed:
        print("\n[RESULT] Verification rejected: Configuration violates Tier 1 safety vectors.")
        sys.exit(1)
    else:
        print("\n[RESULT] Verification successful: Template configuration is secure.")
        sys.exit(0)

if __name__ == "__main__":
    validate_config()
