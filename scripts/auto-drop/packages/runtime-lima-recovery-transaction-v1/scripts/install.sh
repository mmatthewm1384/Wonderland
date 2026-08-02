#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

echo "INSTALL runtime-lima-recovery-transaction-v1"

mkdir -p "$WL_ROOT/vault/governance/runtime/recovery"

cat > "$WL_ROOT/vault/governance/runtime/recovery/recovery-contract.json" <<JSON
{
  "version": "1.0.0",
  "rollback_required": true,
  "preserve_failed_transactions": true,
  "evidence_required": true
}
JSON

echo "INSTALL PASS"
