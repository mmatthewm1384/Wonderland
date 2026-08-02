#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

test -f "$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/lima/readiness_certification.py"

echo "VERIFY PASS"
