#!/usr/bin/env python3
import os
from pathlib import Path

def validate():
    core_path = Path(os.path.expanduser("~/Wonderland/intelligence/obsidian/00-Core"))
    
    # The 'Golden Manifest' of required standards
    required_standards = {
        "Governance.md": "High-level authority definition",
        "operator-authority.md": "Operational access control",
        "registry-authority-decision.md": "Registry truth definition",
        "knowledge-architecture.md": "Information hierarchy",
        "security-standard.md": "Security protocol",
        "recovery-standard.md": "Idempotent recovery procedure"
    }
    
    print(f"\n[AUDITING 00-CORE COMPLETENESS]")
    missing = []
    
    for file, desc in required_standards.items():
        if (core_path / file).exists():
            print(f"  └── [VALID] {file}")
        else:
            print(f"  └── [MISSING] {file} ({desc})")
            missing.append(file)
            
    if not missing:
        print("\nSTATUS: 00-CORE IS COMPLETE (All standards present)")
    else:
        print(f"\nSTATUS: INCOMPLETE (Missing {len(missing)} critical standard(s))")

if __name__ == "__main__":
    validate()
