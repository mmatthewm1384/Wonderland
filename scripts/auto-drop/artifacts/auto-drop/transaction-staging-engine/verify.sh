#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

grep -q "STAGING ARTIFACT" \
"$ROOT/scripts/auto-drop/lib/executor.sh"

echo "Transaction staging verification PASS"
