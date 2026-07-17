#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

echo "== Wonderland wlplatform Import Diagnosis =="

echo
echo "Launcher:"
sed -n '1,120p' "$ROOT/bin/wl-platform"

echo
echo "Searching wlplatform locations..."

find "$ROOT" \
  -type f \
  -name "cli.py" \
  -path "*wlplatform*" \
  2>/dev/null \
  | while read -r file; do
      echo "FOUND:"
      echo "  $file"
      dirname "$(dirname "$file")"
    done

echo
echo "Testing candidate imports..."

python3 <<'PY'
from pathlib import Path
import sys

root = Path("/Users/wonderland/Wonderland")

candidates = []

for p in root.rglob("cli.py"):
    if "wlplatform" in str(p):
        candidates.append(p.parent.parent)

for c in candidates:
    print()
    print("Candidate:", c)

    sys.path.insert(0, str(c))

    try:
        import wlplatform.cli
        print("IMPORT PASS")
        print(wlplatform.cli.__file__)
    except Exception as e:
        print("IMPORT FAIL")
        print(e)

    sys.path.pop(0)
PY
