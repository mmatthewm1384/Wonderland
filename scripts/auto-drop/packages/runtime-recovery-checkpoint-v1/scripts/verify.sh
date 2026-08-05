#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

test -f \
"$WL_ROOT/vault/08-Operations/runtime/recovery-checkpoint/evidence.json"

echo "CERTIFIED"
