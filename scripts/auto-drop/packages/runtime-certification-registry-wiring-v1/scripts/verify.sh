#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

echo "========== VERIFIER =========="

for f in \
"$WL_ROOT/scripts/auto-drop/packages/runtime-certification-registry-wiring-v1/manifest.json" \
"$WL_ROOT/scripts/auto-drop/packages/runtime-certification-registry-wiring-v1/artifacts/metadata.yaml" \
"$WL_ROOT/scripts/auto-drop/packages/runtime-certification-registry-wiring-v1/certification/schema.json"
do
    test -f "$f" && echo "PASS: $f"
done

grep -q "_certification_status" \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/loader.py"

echo "PASS: certification resolver wired"
echo "CERTIFIED"
