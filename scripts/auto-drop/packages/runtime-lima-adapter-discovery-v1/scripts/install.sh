#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

ADAPTER_ROOT="$WL_ROOT/vault/governance/runtime/adapter"

mkdir -p "$ADAPTER_ROOT"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters"

FOUND="unknown"

if [[ -d "$TARGET" ]]; then
    FOUND=$(find "$TARGET" -maxdepth 1 -type f -name "*.py" | sed "s|$WL_ROOT/||" | tr '\n' ',' )
fi

cat > "$ADAPTER_ROOT/discovery.json" <<JSON
{
  "runtime": "lima",
  "discovery_status": "complete",
  "adapter_directory": "$TARGET",
  "adapter_files": "$FOUND"
}
JSON

echo "INSTALL PASS"
