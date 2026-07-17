#!/usr/bin/env bash
set -euo pipefail

ROOT="${WONDERLAND_ROOT:-$(pwd)}"

FILE="$ROOT/builder/python/wlplatform/wlplatform/engine_router.py"

echo "======================================"
echo " Registry Router Inspection"
echo "======================================"
echo

grep -n "registry" "$FILE" || true

echo
echo "Checking registry handler..."

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
text = p.read_text()

checks = [
    "registry",
    "def _registry",
    "execute",
]

for c in checks:
    if c in text:
        print(f"PASS {c}")
    else:
        print(f"MISS {c}")
PY
