#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

TARGET="${WL_ROOT}/scripts/auto-drop/lib/verifier.sh"

rm -f "$TARGET"

echo "PASS: verifier rollback complete"
