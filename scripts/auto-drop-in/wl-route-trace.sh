#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

echo "======================================="
echo "Wonderland Route Trace"
echo "======================================="

echo
echo "--- WL_ROOT ---"
echo "${WL_ROOT:-<unset>}"

echo
echo "--- bin/wl type ---"
file "$ROOT/bin/wl"

echo
echo "--- bin/wl contents ---"
sed -n '1,240p' "$ROOT/bin/wl"

echo
echo "--- direct platform test ---"
"$ROOT/bin/wl-platform" certify trust || true

echo
echo "--- wrapper test ---"
"$ROOT/bin/wl" platform certify trust || true

echo
echo "--- platform launcher ---"
sed -n '1,120p' "$ROOT/bin/wl-platform"

echo
echo "Trace complete."
