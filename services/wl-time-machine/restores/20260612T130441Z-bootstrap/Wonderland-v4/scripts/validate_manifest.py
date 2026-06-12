#!/usr/bin/env python3
import os
import re
from pathlib import Path

def validate_manifest():
    # Corrected Pathing based on your environment
    root = Path(os.path.expanduser("~/Wonderland/intelligence/obsidian"))
    manifest = root / "MANIFEST.md"
    
    if not manifest.exists():
        print(f"CRITICAL: MANIFEST.md not found at {manifest}")
        return

    print(f"\n[AUDITING ARCHITECTURE AGAINST MANIFEST.md]")
    missing = []
    
    with open(manifest, 'r') as f:
        for line in f:
            line = line.strip()
            # Validates against lines that are paths
            if line and not line.startswith(('#', '`', 'Total')):
                file_path = root / line
                if not file_path.exists():
                    print(f"  └── [MISSING] {line}")
                    missing.append(line)

    if not missing:
        print("STATUS: COMPLETE (All files in MANIFEST.md verified on disk)")
    else:
        print(f"\nSTATUS: INCOMPLETE (Found {len(missing)} missing file(s))")

if __name__ == "__main__":
    validate_manifest()
