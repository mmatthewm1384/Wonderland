#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

echo "== Wonderland Certification State Repair =="

cd "$ROOT"

export PYTHONPATH="$ROOT/builder/python:$ROOT/builder/python/wlplatform:$ROOT/builder/python/wlrepository:$ROOT/builder/python/wldoctor:${PYTHONPATH:-}"

echo
echo "Python:"
python3 - <<'PY'
import sys
print(sys.path[0])
for p in sys.path:
    if "Wonderland" in p:
        print(" ", p)
PY

echo
echo "== Certification Graph Rebuild =="

./bin/wl-platform certify graph rebuild

echo
echo "== Certification Trust =="

./bin/wl-platform certify trust

echo
echo "== Platform Verify =="

./bin/wl-platform verify

echo
echo "== COMPLETE =="
