#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

rm -f \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/state/__init__.py"

echo "Rollback complete"
