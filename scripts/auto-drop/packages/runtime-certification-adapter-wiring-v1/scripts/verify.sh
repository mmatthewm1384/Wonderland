#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

echo "========== VERIFIER =========="

for f in \
 "$WL_ROOT/scripts/auto-drop/packages/runtime-certification-adapter-wiring-v1/manifest.json" \
 "$WL_ROOT/scripts/auto-drop/packages/runtime-certification-adapter-wiring-v1/artifacts/metadata.yaml" \
 "$WL_ROOT/scripts/auto-drop/packages/runtime-certification-adapter-wiring-v1/certification/schema.json"
do
    if [[ -f "$f" ]]; then
        echo "PASS: $f"
    else
        echo "FAIL: missing:$f"
        exit 1
    fi
done

echo "CERTIFIED"
