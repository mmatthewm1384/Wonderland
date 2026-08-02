#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:?WL_ROOT is required}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima.py"
BACKUP="${TARGET}.before-idempotent-start"

if [[ -f "$BACKUP" ]]; then
    cp "$BACKUP" "$TARGET"
    echo "ROLLBACK RESTORED"
else
    echo "NO BACKUP REQUIRED"
fi

echo "ROLLBACK PASS"
