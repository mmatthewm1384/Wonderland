#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

echo "== Wonderland Certification CLI Repair =="

export PYTHONPATH="$ROOT/builder/python:${PYTHONPATH:-}"

python3 <<'PY'
import sys
from pathlib import Path

ROOT = Path("/Users/wonderland/Wonderland")

builder = ROOT / "builder/python"

if str(builder) not in sys.path:
    sys.path.insert(0, str(builder))

print("Python path:")
for p in sys.path[:5]:
    print(" ", p)

from wlplatform.cli import build_parser

parser = build_parser()

tests = [
    ["certify", "trust"],
    ["certify", "graph", "status"],
]

for command in tests:
    print()
    print("Testing:", " ".join(command))

    args = parser.parse_args(command)
    print("PASS")
    print(args)

print()
print("Certification CLI routing verified")
PY

echo
echo "Run:"
echo "  wl platform certify trust"
echo "  wl platform certify graph status"
