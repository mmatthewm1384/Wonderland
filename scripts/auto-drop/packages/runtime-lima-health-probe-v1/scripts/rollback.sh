#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

rm -f "$WL_ROOT/vault/governance/runtime/lima/health/health-report.json"

echo "ROLLBACK PASS"
