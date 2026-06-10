#!/usr/bin/env python3
import os
from pathlib import Path

def audit_all_domains():
    obsidian_root = Path(os.path.expanduser("~/Wonderland/intelligence/obsidian"))
    
    print(f"\n[UNIVERSAL DOMAIN AUDIT: {obsidian_root}]")
    
    for domain in sorted([d for d in obsidian_root.iterdir() if d.is_dir()]):
        has_manifest = (domain / "MANIFEST.md").exists()
        has_governance = (domain / "Governance.md").exists()
        
        status = "COMPLETE" if (has_manifest or has_governance) else "INCOMPLETE"
        marker = "✔" if status == "COMPLETE" else "✘"
        
        print(f"  {marker} {domain.name: <25} | Status: {status}")

if __name__ == "__main__":
    audit_all_domains()
