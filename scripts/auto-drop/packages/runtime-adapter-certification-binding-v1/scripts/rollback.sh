#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima_adapter.py"

BACKUP="${TARGET}.runtime-adapter-certification-binding-v1.bak"

if [[ -f "$BACKUP" ]]; then
    cp "$BACKUP" "$TARGET"
fi

echo "Rollback complete"
