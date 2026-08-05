#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

rm -rf \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/certification"

echo "Rollback complete"

