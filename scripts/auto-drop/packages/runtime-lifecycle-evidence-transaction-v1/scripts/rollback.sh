#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"
BACKUP="$TARGET.runtime-lifecycle-evidence-transaction-v1.bak"

test -f "$BACKUP"

cp "$BACKUP" "$TARGET"

echo "Rollback complete"
