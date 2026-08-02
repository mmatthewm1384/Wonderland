#!/bin/sh
set -eu

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

FILE="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/evidence.py"

test -f "$FILE"

echo "PASS runtime evidence collector"
