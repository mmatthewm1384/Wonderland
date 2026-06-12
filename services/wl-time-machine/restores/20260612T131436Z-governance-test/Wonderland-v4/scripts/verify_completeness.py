#!/usr/bin/env python3
import os
import yaml
from pathlib import Path

def audit_completeness():
    obsidian_path = Path(os.path.expanduser("~/Wonderland/intelligence/obsidian"))
    workspace_path = Path(os.path.expanduser("~/Wonderland/Wonderland-v4"))
    
    print(f"\n[AUDITING ARCHITECTURE PARITY]")
    expected_registries = [f.stem for f in obsidian_path.glob("*.yaml")]
    actual_implementations = [f.name for f in workspace_path.iterdir() if f.is_dir()]
    
    missing = [reg for reg in expected_registries if reg not in actual_implementations]
    
    if not missing:
        print("STATUS: COMPLETE (100% Alignment verified)")
    else:
        print(f"STATUS: INCOMPLETE (Missing {len(missing)} nodes)")
        for item in missing:
            print(f"  └── WARNING: Registry '{item}' exists in Obsidian but has no workspace node.")

if __name__ == "__main__":
    audit_completeness()
