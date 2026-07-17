#!/usr/bin/env bash
set -euo pipefail

echo "Testing Wonderland registry command..."

if ! wl commands | grep -q "registry"; then
    echo "FAIL: wl registry missing from command registry"
    exit 1
fi

if ! grep -q '"registry"' \
    builder/python/wlplatform/wlplatform/cli.py; then
    echo "FAIL: platform registry handler missing"
    exit 1
fi

echo "PASS: registry command projection verified"
