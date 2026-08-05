#!/usr/bin/env bash
set -euo pipefail

echo "Installing runtime certification reconciliation"

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

mkdir -p "$WL_ROOT/vault/08-Operations/certifications/runtime"

cat > "$WL_ROOT/vault/08-Operations/certifications/runtime/runtime-certification-reconciliation-v1.json" <<JSON
{
  "component": "runtime",
  "certification": "runtime-certification-reconciliation-v1",
  "status": "installed",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON

echo "Installed"
