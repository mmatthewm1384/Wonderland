#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

test -f "$WL_ROOT/vault/governance/runtime/recovery/recovery-contract.json"

echo "VERIFY PASS"
