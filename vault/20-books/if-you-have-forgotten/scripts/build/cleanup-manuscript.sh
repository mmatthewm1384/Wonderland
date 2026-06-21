#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MANUSCRIPT="$ROOT/manuscript"

echo "[*] Cleaning manuscript..."

find "$MANUSCRIPT" -type f -name '*.md' | while read -r file; do

  # Remove ChatGPT code fences
  sed -i '' '/^```/d' "$file"

  # Remove writing block wrappers
  sed -i '' '/^:::writing/d' "$file"
  sed -i '' '/^:::$/d' "$file"

  # Remove stray id="..." lines
  sed -i '' '/id="/d' "$file"

done

echo "[ok] manuscript cleaned"
