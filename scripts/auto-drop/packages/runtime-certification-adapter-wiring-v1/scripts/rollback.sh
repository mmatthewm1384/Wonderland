#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

rm -f \
 "$WL_ROOT/vault/08-Operations/certifications/runtime/runtime-certification-adapter-wiring-v1.json"

echo "Rollback complete"
