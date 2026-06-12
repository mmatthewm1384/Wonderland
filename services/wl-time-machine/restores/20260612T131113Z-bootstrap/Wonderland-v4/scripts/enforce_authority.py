#!/usr/bin/env python3
import os
import yaml
from pathlib import Path

def enforce_authority():
    governance_dir = Path(os.path.expanduser("~/Wonderland/intelligence/obsidian/governance"))
    workspace = Path(os.path.expanduser("~/Wonderland/Wonderland-v4/services"))
    
    print("[AUTHORITY CHECK: Obsidian -> Runtime]")
    
    # Audit logic: The governance directory IS the authority
    for registry in governance_dir.glob("*.yaml"):
        service_name = registry.stem
        service_path = workspace / service_name
        
        if not service_path.exists():
            print(f"  └── NON-COMPLIANCE: {service_name} defined in Obsidian but absent in Runtime.")
        else:
            print(f"  └── VERIFIED: {service_name} exists in Runtime and Governance.")

if __name__ == "__main__":
    enforce_authority()
