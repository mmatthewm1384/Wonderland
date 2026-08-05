#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET_DIR="$WL_ROOT/runtime/contracts"

mkdir -p "$TARGET_DIR"

cp \
"$(dirname "$0")/artifacts/runtime-contract-v1.yaml" \
"$TARGET_DIR/runtime-contract-v1.yaml"

echo "runtime-contract-v1 installed"
echo "location: $TARGET_DIR/runtime-contract-v1.yaml"
