#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/inventory.py"

cp \
"$TARGET.runtime-inventory-certification-resolution-v1.bak" \
"$TARGET"

echo Rollback complete
