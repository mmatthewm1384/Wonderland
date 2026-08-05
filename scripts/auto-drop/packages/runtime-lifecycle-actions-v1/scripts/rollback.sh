#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

rm -f \
"$WL_ROOT/vault/08-Operations/runtime/lifecycle-actions.json"

echo "Rollback complete"
