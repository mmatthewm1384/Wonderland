#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

LAUNCHER="$ROOT/bin/wl-platform"

CANONICAL="$ROOT/builder/python/wlplatform"

echo "=========================================="
echo "Wonderland Python Path Authority Repair"
echo "=========================================="

if [ ! -f "$LAUNCHER" ]; then
    echo "ERROR: launcher missing:"
    echo "$LAUNCHER"
    exit 1
fi

cp "$LAUNCHER" \
"$LAUNCHER.backup.$(date +%Y%m%d-%H%M%S)"

echo
echo "--- Checking launcher ---"

if grep -q "builder/python/wlplatform" "$LAUNCHER"; then
    echo "Canonical path already present"
else

python3 <<PY
from pathlib import Path

path = Path(
"$LAUNCHER"
)

text = path.read_text()

marker = "import sys"

if marker not in text:
    raise SystemExit(
        "Could not locate import section"
    )

replacement = """import sys

# Wonderland canonical Python authority path
sys.path.insert(
    0,
    "/Users/wonderland/Wonderland/builder/python/wlplatform"
)
"""

text = text.replace(
    marker,
    replacement,
    1
)

path.write_text(text)

print(
    "Injected canonical Wonderland Python path"
)
PY

fi


echo
echo "--- Verify import authority ---"

PYTHONPATH="$CANONICAL:${PYTHONPATH:-}" \
python3 <<'PY'
import wlplatform
import wlplatform.cli

print(
    "wlplatform:",
    wlplatform.__file__
)

print(
    "cli:",
    wlplatform.cli.__file__
)
PY


echo
echo "--- Duplicate package search ---"

python3 - <<'PY'
import sys
import site
import glob

paths = []

try:
    paths.extend(site.getsitepackages())
except Exception:
    pass

try:
    paths.append(site.getusersitepackages())
except Exception:
    pass

for base in paths:
    matches = glob.glob(
        base + "/**/wlplatform*",
        recursive=True
    )

    for item in matches:
        print(item)
PY


echo
echo "Repair complete"
