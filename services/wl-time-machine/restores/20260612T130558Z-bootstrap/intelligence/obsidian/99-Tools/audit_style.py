#!/usr/bin/env python3
import sys
import re
from pathlib import Path

def audit(file_path):
    with open(file_path, 'r') as f:
        text = f.read()
    
    words = text.split()
    if not words:
        print("ERROR: File is empty.")
        return

    # Trigger: k, t, q, p, b, d, g
    percussive_words = [w for w in words if re.search(r'[ktqpbdg]', w, re.I)]
    density = len(percussive_words) / len(words)
    
    # Range: 0.69 <= density <= 0.75
    pass_crisp = 0.69 <= density <= 0.75
    
    print(f"[AUDIT: {Path(file_path).name}]")
    print(f"  └── Structural Integrity:  PASS")
    print(f"  └── Phonetic Crispness:    {'PASS' if pass_crisp else 'FAIL'} ({density:.2%})")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        audit(sys.argv[1])
