#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$ROOT/builder/python/wlplatform/wlplatform/certification_state.py"

echo "Patching:"
echo "$FILE"

cp "$FILE" "$FILE.backup.$(date +%Y%m%d-%H%M%S)"

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

old = '''"engines": active,'''

new = '''"engines": {
                name: {
                    **data,
                    "status": (
                        data.get("status")
                        or (
                            "PASS"
                            if data.get("certified")
                            else "FAIL"
                        )
                    ),
                }
                for name, data in active.items()
            },'''

if old not in text:
    raise SystemExit(
        "Target block not found"
    )

text = text.replace(old, new)

path.write_text(text)

print("PATCH COMPLETE")
PY

PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 -m compileall \
"$ROOT/builder/python/wlplatform/wlplatform"

echo "DONE"
