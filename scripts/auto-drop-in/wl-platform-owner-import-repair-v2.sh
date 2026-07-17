#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

CLI="$ROOT/builder/python/wlplatform/wlplatform/cli.py"

echo "Repairing invalid wlplatform owner import"

cp "$CLI" "$CLI.backup.$(date +%Y%m%d-%H%M%S)"

python3 - <<'PY'
from pathlib import Path

path = Path(
"/Users/wonderland/Wonderland/builder/python/wlplatform/wlplatform/cli.py"
)

lines = path.read_text().splitlines()

output = []
inside = False

for line in lines:

    if "from .engines.capabilities import (" in line:
        inside = True
        output.append(line)
        continue

    if inside and line.strip() == ")":
        inside = False
        output.append(line)
        continue

    if inside and line.strip().startswith("owner"):
        print("Removing:", line)
        continue

    output.append(line)

path.write_text("\n".join(output) + "\n")

print("Repair complete")
PY


echo
echo "Checking remaining owner imports:"
grep -n "owner" "$CLI" || true
