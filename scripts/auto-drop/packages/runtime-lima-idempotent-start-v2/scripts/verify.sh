#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

test -f "$WL_ROOT/vault/governance/runtime/lima/idempotent-start-policy.json"

echo "VERIFY PASS"
