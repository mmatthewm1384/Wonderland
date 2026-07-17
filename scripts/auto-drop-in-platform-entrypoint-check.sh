#!/usr/bin/env bash
set -euo pipefail

ROOT="${WONDERLAND_ROOT:-$(pwd)}"

echo "======================================"
echo " Platform Entrypoint Check"
echo "======================================"

echo
echo "bin/wl-platform:"
sed -n '1,120p' "$ROOT/bin/wl-platform"

echo
echo "References:"
grep -R "wlplatform.cli\|main(" \
    "$ROOT/bin/wl-platform" \
    "$ROOT/builder/python/wlplatform" \
    2>/dev/null || true
