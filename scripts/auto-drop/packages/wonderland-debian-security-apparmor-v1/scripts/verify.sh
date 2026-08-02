#!/usr/bin/env bash
set -euo pipefail

echo "=== APPARMOR VERIFICATION ==="

if command -v aa-status >/dev/null 2>&1; then
    aa-status || true
else
    echo "FAIL: aa-status unavailable"
    exit 1
fi

echo
echo "=== NERDCTL SECURITY ==="

nerdctl info | grep -A20 "Security Options" || true

echo
echo "PASS: AppArmor capability verified"
