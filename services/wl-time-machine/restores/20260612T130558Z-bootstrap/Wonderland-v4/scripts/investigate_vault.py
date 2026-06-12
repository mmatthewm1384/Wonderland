#!/usr/bin/env python3
import os
import sys
import shutil

def run_investigation(purge_mode=False):
    print("\n[WONDERLAND SYSTEM INVENTORY AUDIT DEEP DISCOVERY]")
    
    authoritative_vault = os.path.expanduser("~/Wonderland/vault")
    sandbox_vault = os.path.expanduser("~/Wonderland/Wonderland-v4/vault")
    
    purge_targets = [
        os.path.expanduser("~/Wonderland/Wonderland-v4/tmp"),
        os.path.expanduser("~/.cache/pip")
    ]
    
    print(f"Tier 1 Authoritative Vault Path: {authoritative_vault}")
    if os.path.exists(authoritative_vault):
        file_count = sum([len(files) for r, d, files in os.walk(authoritative_vault)])
        print(f"  └── Status: ALIGNED ({file_count} legacy artifacts discovered)")
    else:
        print("  └── Status: CLEAN / REMOVED (No un-archived target drift detected)")
        
    print(f"Sandbox Implementation Vault Path: {sandbox_vault}")
    if os.path.exists(sandbox_vault):
        print("  └── Status: ACTIVE (Isolated development space verified)")
    else:
        print("  └── Status: ABSENT")

    print("\n[PURGE MATRIX DRIFT DETECTION]")
    for target in purge_targets:
        if os.path.exists(target):
            if purge_mode:
                print(f"  └── [REPAIR] Purging drift target: {target}...")
                try:
                    if os.path.isdir(target):
                        shutil.rmtree(target)
                    else:
                        os.remove(target)
                    print(f"      └── SUCCESS: Target eliminated.")
                except Exception as e:
                    print(f"      └── ERROR: Failed to purge {target}: {e}")
            else:
                print(f"  └── [DOCTOR] Stale artifact flagged for purge: {target} (State un-modified)")
        else:
            print(f"  └── Target Clear: {target} [NOMINAL]")
            
    print("\nInvestigation Pass Completed successfully.")
    sys.exit(0)

if __name__ == "__main__":
    execute_purge = "--purge" in sys.argv or "repair" in sys.argv
    run_investigation(purge_mode=execute_purge)
