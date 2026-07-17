#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

CLI="$ROOT/builder/python/wlplatform/wlplatform/cli.py"

echo "Checking certification routes"

grep -n "certify" "$CLI"

echo
echo "Current certify implementation located."
echo "No mutation performed."
