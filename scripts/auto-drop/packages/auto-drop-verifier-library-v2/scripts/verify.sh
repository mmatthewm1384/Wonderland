#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

TARGET="$WL_ROOT/scripts/auto-drop/lib/verifier.sh"

echo "VERIFIER AUTHORITY CHECK"
echo "------------------------"

if [[ ! -f "$TARGET" ]]; then
    echo "FAIL: canonical verifier missing"
    exit 1
fi

if [[ ! -x "$TARGET" ]]; then
    echo "FAIL: canonical verifier not executable"
    exit 1
fi

if ! grep -q "run_package_verifier" "$TARGET"; then
    echo "FAIL: verifier contract missing"
    exit 1
fi

echo "PASS: canonical verifier"
echo "PASS: run_package_verifier contract"
