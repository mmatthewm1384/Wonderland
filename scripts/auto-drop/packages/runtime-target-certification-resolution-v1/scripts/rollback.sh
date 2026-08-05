#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/loader.py"

if [ -f "$TARGET.certification-resolution-backup" ]; then
    mv "$TARGET.certification-resolution-backup" "$TARGET"
fi

echo rollback-complete
