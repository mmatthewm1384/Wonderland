#!/bin/sh
set -eu

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

rm -f \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/validator.py"

echo "runtime target validation rollback complete"
