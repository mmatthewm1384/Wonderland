#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

TARGET="$WL_ROOT/vault/governance/runtime/lima"

mkdir -p "$TARGET"

cat > "$TARGET/idempotent-start-policy.json" <<JSON
{
  "version": "2.0.0",
  "runtime": "lima",
  "instance": "wonderland-rootless",
  "behavior": {
    "existing_running_vm": "reuse",
    "missing_vm": "start",
    "failed_start": "preserve_transaction"
  }
}
JSON

echo "INSTALL PASS"
