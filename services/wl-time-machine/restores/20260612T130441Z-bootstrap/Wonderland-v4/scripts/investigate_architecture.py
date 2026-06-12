#!/usr/bin/env python3
import os
import sys
import re
import shutil

def run_architecture_audit(purge_mode=False):
    print("\n[WONDERLAND SYSTEM ARCHITECTURE AUDIT & ALIGNMENT]")
    
    base_dir = os.path.expanduser("~/Wonderland")
    v4_dir = os.path.expanduser("~/Wonderland/Wonderland-v4")
    obsidian_brain = os.path.join(base_dir, "intelligence", "obsidian")
    
    print(f"Tier 1 Authoritative Core: {obsidian_brain}")
    if os.path.exists(obsidian_brain):
        print("  └── Status: NOMINAL (True Obsidian brain verified)")
    else:
        print("  └── WARNING: Tier 1 Knowledge Core not found at this location!")

    targets_to_purge = []
    
    sandbox_vault = os.path.join(v4_dir, "vault")
    if os.path.exists(sandbox_vault):
        targets_to_purge.append(sandbox_vault)
        
    if os.path.exists(base_dir):
        numerical_pattern = re.compile(r"^\d{2}-")
        for item in os.listdir(base_dir):
            item_path = os.path.join(base_dir, item)
            if os.path.isdir(item_path) and numerical_pattern.match(item):
                targets_to_purge.append(item_path)

    print("\n[PURGE MATRIX ARTIFACT ALIGNMENT]")
    if not targets_to_purge:
        print("  └── Structure Aligned. No non-compliant architectural drift detected. [NOMINAL]")
        sys.exit(0)
        
    for target in targets_to_purge:
        if purge_mode:
            print(f"  └── [REPAIR] Purging architecture drift: {target}...")
            try:
                if os.path.isdir(target):
                    shutil.rmtree(target)
                else:
                    os.remove(target)
                print(f"      └── SUCCESS: Non-aligned element eliminated.")
            except Exception as e:
                print(f"      └── ERROR: Failed to execute drop on {target}: {e}")
        else:
            print(f"  └── [DOCTOR] Architecture Drift Flagged: {target} (Run with --purge to align)")
            
    if not purge_mode:
        print("\nAudit complete. Run your operational utility with '--purge' or 'repair' to clear flagged paths.")
    else:
        print("\nPurge complete. Stale architectural nodes cleaned successfully.")
        
    sys.exit(0)

if __name__ == "__main__":
    execute_purge = "--purge" in sys.argv or "repair" in sys.argv
    run_architecture_audit(purge_mode=execute_purge)
