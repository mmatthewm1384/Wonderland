#!/usr/bin/env bash
set -euo pipefail

COMPOSER="$HOME/Wonderland/Crystal/us/sparks/composer/compose.sh"

echo "=== Fix Spark Composer YAML Newlines ==="

cp "$COMPOSER" "$COMPOSER.backup.$(date +%Y%m%d-%H%M%S)"

python3 <<'PY'
from pathlib import Path

p = Path.home() / "Wonderland/Crystal/us/sparks/composer/compose.sh"

s = p.read_text()

s = s.replace(
    '# Wonderland Spark VM Profile\\n\\nname:',
    '# Wonderland Spark VM Profile\n\nname:'
)

p.write_text(s)
PY

echo "[PASS] Newline fix applied"
