#!/usr/bin/env bash

set -euo pipefail

CLI="/Users/wonderland/Wonderland/builder/python/wlplatform/wlplatform/cli.py"

echo "=== certify dispatch ==="

grep -n 'args.command == "certify"' "$CLI"

echo

sed -n '600,720p' "$CLI"
