#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

test -f \
"$WL_ROOT/scripts/auto-drop/packages/runtime-certification-registry-wiring-v2/manifest.json"

test -f \
"$WL_ROOT/scripts/auto-drop/packages/runtime-certification-registry-wiring-v2/artifacts/metadata.yaml"

test -f \
"$WL_ROOT/scripts/auto-drop/packages/runtime-certification-registry-wiring-v2/certification/schema.json"

python3 -m compileall \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/loader.py"

echo "CERTIFIED"
