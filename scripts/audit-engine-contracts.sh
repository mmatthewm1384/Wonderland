#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=== Engine verify implementations ==="

grep -R "def verify" \
builder/python/wlplatform/wlplatform/engines \
|| true

echo
echo "=== Engines returning raw dictionaries ==="

grep -R "return {" \
builder/python/wlplatform/wlplatform/engines \
|| true

echo
echo "=== Contract audit complete ==="
