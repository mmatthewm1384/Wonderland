#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

rm -f "$WL_ROOT/vault/governance/runtime/adapter/discovery.json"

echo "ROLLBACK PASS"
