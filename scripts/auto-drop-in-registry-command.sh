#!/usr/bin/env bash
set -euo pipefail

ROOT="${WONDERLAND_ROOT:-$(pwd)}"

FILE="$ROOT/builder/python/wlcli/wlcli/registry.py"

echo "======================================"
echo " Wonderland Registry Command Drop-In"
echo "======================================"
echo
echo "Target:"
echo "$FILE"
echo

if grep -q 'Command("registry"' "$FILE"; then
    echo "PASS: registry command already exists"
    exit 0
fi

echo "Adding registry public command..."

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

anchor = '''        Command(
            "platform",
            "Engineering",
            "Manage Wonderland Platform Engine verification and certification",
            target="wl-platform",
        ),
'''

insert = '''
        Command(
            "registry",
            "Engineering",
            "Show Wonderland public command registry and ownership projection",
            target="wl-platform",
        ),
'''

if '"registry"' in text:
    print("Registry command already present.")
    sys.exit(0)

if anchor not in text:
    raise SystemExit(
        "ERROR: insertion point not found"
    )

text = text.replace(
    anchor,
    anchor + insert,
)

path.write_text(text)

print("Registry command inserted.")
PY

echo
echo "Verification:"
echo
echo "  wl commands | grep registry"
echo
echo "======================================"
