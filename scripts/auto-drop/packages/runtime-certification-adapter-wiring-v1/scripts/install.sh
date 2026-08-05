#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET_FILE="$WL_ROOT/vault/08-Operations/certifications/runtime/runtime-certification-adapter-wiring-v1.json"

mkdir -p "$(dirname "$TARGET_FILE")"

cat > "$TARGET_FILE" <<JSON
{
  "component": "runtime",
  "adapter": "certification-wiring",
  "target": "wonderland-rootless",
  "certified": true,
  "evidence": "runtime-certification-reconciliation-v1"
}
JSON

echo "Runtime certification adapter wiring installed"
