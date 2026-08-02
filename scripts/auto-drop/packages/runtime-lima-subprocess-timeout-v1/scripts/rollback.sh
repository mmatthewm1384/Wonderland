#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

rm -f "$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/subprocess_timeout.py"

echo "ROLLBACK PASS"
