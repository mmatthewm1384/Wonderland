#!/usr/bin/env bash
set -euo pipefail

TARGET="${WL_ROOT:-/Users/wonderland/Wonderland}/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima.py"

grep -q "already_running" "$TARGET"

echo "VERIFY PASS"
