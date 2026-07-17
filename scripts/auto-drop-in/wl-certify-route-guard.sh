#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"
CLI="$ROOT/builder/python/wlplatform/wlplatform/cli.py"

echo "======================================"
echo "Wonderland Certification Route Guard"
echo "======================================"

if grep -q 'if command == "certify":' "$CLI"; then
    echo "Certification route guard already installed"
else
    cp "$CLI" \
    "$CLI.backup.$(date +%Y%m%d-%H%M%S)"

    python3 <<'PY'
from pathlib import Path

path = Path(
"/Users/wonderland/Wonderland/builder/python/wlplatform/wlplatform/cli.py"
)

text = path.read_text()

old = """    command = argv[0]

    if command in ENGINE_COMMANDS:
"""

new = """    command = argv[0]

    # Preserve nested certification commands:
    # wl platform certify trust
    # wl platform certify graph status

    if command == "certify":
        return argv

    if command in ENGINE_COMMANDS:
"""

if old not in text:
    raise SystemExit(
        "Could not find routing insertion point"
    )

text = text.replace(
    old,
    new,
    1
)

path.write_text(text)

print(
    "Certification route guard installed"
)
PY
fi


echo
echo "=== Route Verification ==="

python3 <<'PY'
import sys

sys.path.insert(
    0,
    "/Users/wonderland/Wonderland/builder/python/wlplatform"
)

from wlplatform.cli import route_engine_argv

tests = [
    ["certify", "trust"],
    ["certify", "graph", "status"],
]

for item in tests:
    result = route_engine_argv(item)

    print(
        item,
        "=>",
        result
    )

    assert result == item

print(
    "Certification routing PASS"
)
PY


echo
echo "======================================"
echo "Run:"
echo "  wl platform certify trust"
echo "  wl platform certify graph status"
echo "======================================"
