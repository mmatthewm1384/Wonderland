#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/Wonderland/Crystal/us/sparks/composer/compose.sh"

echo "=== Removing invalid Lima YAML name field ==="

cp "$FILE" "$FILE.backup.$(date +%Y%m%d-%H%M%S)"

python3 <<'PY'
from pathlib import Path

p = Path.home() / "Wonderland/Crystal/us/sparks/composer/compose.sh"

lines = p.read_text().splitlines()

out = []
skip_next = False

for line in lines:
    if line.strip().startswith("name:"):
        continue
    out.append(line)

p.write_text("\n".join(out) + "\n")
PY

echo "[PASS] name field removed"
