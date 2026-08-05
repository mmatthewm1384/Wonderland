#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/loader.py"

if [[ -f "$TARGET.runtime-target-certification-provider-v1.bak" ]]; then
    cp "$TARGET.runtime-target-certification-provider-v1.bak" "$TARGET"
fi

echo "Rollback complete"
