#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "========== RUNTIME CONTRACT VERIFIER =========="

echo "Package:"
echo "$PACKAGE_ROOT"

fail() {
    echo "FAIL: $1"
    exit 1
}

test -f "$PACKAGE_ROOT/certification/schema.json" \
    || fail "certification/schema.json missing"

echo "PASS: certification/schema.json"

test -f "$PACKAGE_ROOT/certification/runtime-contract.json" \
    || fail "certification/runtime-contract.json missing"

echo "PASS: certification/runtime-contract.json"
