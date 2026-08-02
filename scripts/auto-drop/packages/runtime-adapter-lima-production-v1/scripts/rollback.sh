#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

TARGET="$ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima.py"

BACKUP="$ROOT/builder/python/wlplatform/migration/backups/runtime-adapter-lima-production-v1"


if [[ -f "$TARGET" ]]; then

    mkdir -p "$BACKUP"

    mv "$TARGET" "$BACKUP/"

fi


echo "LIMA ADAPTER ROLLBACK PASS"

