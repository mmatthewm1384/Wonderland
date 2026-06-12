#!/usr/bin/env python3
import subprocess
from pathlib import Path

# Scan all markdown files in the core and registry folders
files = list(Path('~/Wonderland/intelligence/obsidian/').glob('**/*.md'))

for f in files:
    # Run the existing audit_style.py against each file
    result = subprocess.run(['python3', '~/Wonderland/intelligence/obsidian/99-Tools/audit_style.py', str(f)], capture_output=True, text=True)
    print(result.stdout)
