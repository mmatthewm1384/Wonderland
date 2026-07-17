#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

CLI="$ROOT/builder/python/wlplatform/wlplatform/cli.py"
CAP="$ROOT/builder/python/wlplatform/wlplatform/engines/capabilities.py"

echo "Wonderland Platform Owner Import Repair"

if ! grep -q "owner" "$CAP"; then

    echo "Missing owner export detected"

    cp "$CLI" "$CLI.backup.$(date +%Y%m%d-%H%M%S)"

    python3 - <<'PY'
from pathlib import Path

p = Path(
"/Users/wonderland/Wonderland/builder/python/wlplatform/wlplatform/cli.py"
)

text = p.read_text()

old = """
    owner,
"""

if old in text:
    text = text.replace(old, "")

p.write_text(text)

print("Removed invalid owner import")
PY

else
    echo "Owner already exists. No change."
fi


echo
echo "Verification:"
python3 - <<'PY'
import sys
sys.path.insert(
0,
"/Users/wonderland/Wonderland/builder/python/wlplatform"
)

import wlplatform.cli

print("wlplatform import PASS")
PY

echo
echo "Repair complete"
