#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

BACKUP="${TARGET}.runtime-adapter-resolution-v1.bak"

if [[ -f "$BACKUP" ]]; then
    cp "$BACKUP" "$TARGET"
fi

echo "Rollback complete"
