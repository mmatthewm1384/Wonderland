#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

BACKUP="$TARGET.runtime-evidence-binding-backup"

if [ -f "$BACKUP" ]; then
    mv "$BACKUP" "$TARGET"
fi

echo rollback-complete
