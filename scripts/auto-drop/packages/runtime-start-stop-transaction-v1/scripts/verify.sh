#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

test -f \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

grep -q "_transaction_event" \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

echo "CERTIFIED"
