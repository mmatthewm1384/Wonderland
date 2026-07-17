#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

echo "================================"
echo "Wonderland CLI Path Diagnostic"
echo "================================"

echo
echo "--- wl executable ---"
which wl || true

echo
echo "--- wl-platform executable ---"
which wl-platform || true

echo
echo "--- project wrapper ---"
sed -n '1,80p' "$ROOT/bin/wl-platform"

echo
echo "--- Python import path ---"

PYTHONPATH="$ROOT/builder/python/wlplatform:${PYTHONPATH:-}" \
python3 <<'PY'
import sys
import wlplatform
import wlplatform.cli

print("wlplatform:")
print(wlplatform.__file__)

print()
print("wlplatform.cli:")
print(wlplatform.cli.__file__)

print()
print("sys.path:")
for p in sys.path:
    print(p)
PY


echo
echo "--- duplicate wlplatform trees ---"

find "$ROOT" \
-path "*wlplatform*" \
-type d \
-maxdepth 6 \
2>/dev/null | sort
