#!/bin/sh
set -eu

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

FILE="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/integration.py"

if [ -f "$FILE" ]; then
    echo "PASS runtime integration"
    exit 0
fi

echo "FAIL runtime integration missing"
exit 1
