#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

REGISTRY="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/registry.json"

if [[ -f "$REGISTRY.runtime-primary-certification-registration-v1.bak" ]]; then
    cp \
    "$REGISTRY.runtime-primary-certification-registration-v1.bak" \
    "$REGISTRY"
fi

echo "Rollback complete"

