#!/bin/sh
set -eu

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

rm -f \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/lifecycle.py"

echo "runtime lifecycle governance rollback complete"
