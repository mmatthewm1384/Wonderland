#!/usr/bin/env bash
set -euo pipefail

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima.py"

BACKUP="$TARGET.before-runtime-lima-readiness-hardening"

echo "RUNTIME LIMA READINESS ROLLBACK"
echo "================================"

if [[ -f "$BACKUP" ]]; then
    mv "$BACKUP" "$TARGET"
    echo "Rollback restored"
else
    echo "No backup found"
fi

echo "ROLLBACK PASS"
