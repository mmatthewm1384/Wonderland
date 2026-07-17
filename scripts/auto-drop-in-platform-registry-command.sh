#!/usr/bin/env bash
set -euo pipefail

ROOT="${WONDERLAND_ROOT:-$(pwd)}"

FILE="$ROOT/builder/python/wlplatform/wlplatform/cli.py"

echo "======================================"
echo " Wonderland Platform Registry Drop-In"
echo "======================================"
echo

grep -n "registry" "$FILE" || true

echo
echo "Inspecting parser ownership..."

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

if "verify_registry" not in text:
    raise SystemExit(
        "ERROR: registry adapter not imported"
    )

if '"registry"' in text and "add_parser" in text:
    print("Registry references already exist.")
else:
    print(
        "Registry implementation exists but parser route is missing."
    )

PY
