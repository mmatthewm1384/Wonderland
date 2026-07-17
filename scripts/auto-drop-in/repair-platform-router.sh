#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

echo "======================================"
echo " Wonderland Platform Router Repair"
echo "======================================"

WL="$ROOT/bin/wl"
PLATFORM="$ROOT/bin/wl-platform"

if [[ ! -x "$WL" ]]; then
    echo "FAIL: missing executable $WL"
    exit 1
fi

if [[ ! -x "$PLATFORM" ]]; then
    echo "FAIL: missing executable $PLATFORM"
    exit 1
fi


echo
echo "[1/5] Checking wl dispatcher"

if ! grep -q "wl-platform" "$WL"; then
    echo "FAIL: wl dispatcher does not delegate to wl-platform"
    exit 1
fi

echo "PASS"


echo
echo "[2/5] Checking Python module resolution"

PYTHONPATH="$ROOT/builder/python${PYTHONPATH:+:$PYTHONPATH}" \
python3 <<'PY'
import sys

sys.path.insert(
    0,
    "/Users/wonderland/Wonderland/builder/python"
)

import wlplatform
from wlplatform.cli import build_parser

print("wlplatform:")
print(wlplatform.__file__)

parser = build_parser()

tests = [
    ["certify", "trust"],
    ["certify", "graph", "status"],
]

for test in tests:
    args = parser.parse_args(test)
    print("PASS", test, args)
PY


echo
echo "[3/5] Testing direct platform binary"

"$PLATFORM" certify trust >/dev/null

echo "PASS"


echo
echo "[4/5] Testing wl wrapper"

"$WL" platform certify trust >/dev/null

echo "PASS"


echo
echo "[5/5] Testing user command"

command -v wl >/dev/null

echo
echo "======================================"
echo " PASS: Platform routing healthy"
echo "======================================"
