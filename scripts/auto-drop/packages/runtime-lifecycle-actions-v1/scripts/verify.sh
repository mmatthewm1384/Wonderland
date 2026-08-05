#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

test -f \
"$WL_ROOT/scripts/auto-drop/packages/runtime-lifecycle-actions-v1/manifest.json"

test -f \
"$WL_ROOT/scripts/auto-drop/packages/runtime-lifecycle-actions-v1/artifacts/metadata.yaml"

test -f \
"$WL_ROOT/scripts/auto-drop/packages/runtime-lifecycle-actions-v1/certification/schema.json"

echo "CERTIFIED"
