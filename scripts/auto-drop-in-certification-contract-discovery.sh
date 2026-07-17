#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

echo "== Certification Contract Discovery =="

grep -R \
"status.*PASS\|status.*FAIL\|certified.*true\|certified.*false" \
builder/python/wlplatform/wlplatform \
--exclude="*.bak*" \
--exclude="*.backup*" \
> /tmp/wl-cert-contract-search.txt || true

echo
echo "Results:"
cat /tmp/wl-cert-contract-search.txt
