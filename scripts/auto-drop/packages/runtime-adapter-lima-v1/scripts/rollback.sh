#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

rm -f \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima_adapter.py"

echo "Rollback complete"
