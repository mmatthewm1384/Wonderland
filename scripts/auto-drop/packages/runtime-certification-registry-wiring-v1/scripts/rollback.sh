#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/loader.py"
BACKUP="$TARGET.runtime-certification-registry-wiring-v1.bak"

if [[ -f "$BACKUP" ]]; then
    mv "$BACKUP" "$TARGET"
fi

echo "Rollback complete"
