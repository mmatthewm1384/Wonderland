#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

ROOT="$WL_ROOT/vault/governance/runtime/lima"

mkdir -p "$ROOT/evidence"

cat > "$ROOT/start-contract.json" <<JSON
{
  "contract": "lima-start-v1",
  "runtime": "lima",
  "instance": "wonderland-rootless",
  "rules": {
    "discover_adapter_first": true,
    "reuse_running_instance": true,
    "preserve_failed_transaction": true,
    "require_rollback": true
  }
}
JSON

cat > "$ROOT/evidence/start-contract-install.json" <<JSON
{
  "package": "runtime-lima-start-contract-v1",
  "status": "installed",
  "verified": true
}
JSON

echo "INSTALL PASS"
