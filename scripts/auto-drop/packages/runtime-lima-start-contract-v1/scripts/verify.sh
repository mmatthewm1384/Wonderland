#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

test -f "$WL_ROOT/vault/governance/runtime/lima/start-contract.json"
test -f "$WL_ROOT/vault/governance/runtime/lima/evidence/start-contract-install.json"

echo "VERIFY PASS"
