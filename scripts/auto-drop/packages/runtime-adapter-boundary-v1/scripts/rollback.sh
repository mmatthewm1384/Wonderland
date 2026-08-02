#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

TARGET="$ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters"
BACKUP="$ROOT/builder/python/wlplatform/migration/backups/runtime-adapter-boundary-v1"

if [[ -d "$TARGET" ]]; then
    mkdir -p "$(dirname "$BACKUP")"
    mv "$TARGET" "$BACKUP"
fi

echo "RUNTIME ADAPTER ROLLBACK PASS"
