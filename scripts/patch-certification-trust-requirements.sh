#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$ROOT/builder/python/wlplatform/wlplatform/certification_state.py"

echo "Patching:"
echo "$FILE"

if [[ ! -f "$FILE" ]]; then
    echo "ERROR: file not found"
    exit 1
fi

BACKUP="$FILE.backup.$(date +%Y%m%d-%H%M%S)"
cp "$FILE" "$BACKUP"

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

old = '''missing = [
            x
            for x in [
                "academy",
                "architecture",
                "builder",
                "runtime",
                "security",
            ]
            if x not in active
        ]'''

new = '''required_engines = [
            "architecture",
            "builder",
            "governance",
            "registry",
            "repository",
            "runtime",
            "academy",
            "mirror",
        ]

        missing = [
            x
            for x in required_engines
            if x not in active
        ]'''

if old not in text:
    print("ERROR: target block not found")
    print("No changes made")
    sys.exit(1)

text = text.replace(old, new)

path.write_text(text)

print("PATCH COMPLETE")
PY

echo
echo "Backup:"
echo "$BACKUP"

echo
echo "Validation:"
PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 -m compileall \
"$ROOT/builder/python/wlplatform/wlplatform"

echo
echo "DONE"
