#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

echo "========== VERIFIER =========="

echo "PACKAGE: runtime-certification-reconciliation-v1"

for f in \
 "$WL_ROOT/scripts/auto-drop/packages/runtime-certification-reconciliation-v1/manifest.json" \
 "$WL_ROOT/scripts/auto-drop/packages/runtime-certification-reconciliation-v1/artifacts/metadata.yaml" \
 "$WL_ROOT/vault/08-Operations/certifications/runtime/runtime-certification-reconciliation-v1.json"
do
    if [[ -f "$f" ]]; then
        echo "PASS: $f"
    else
        echo "FAIL: missing:$f"
        exit 1
    fi
done

echo "CERTIFIED"
