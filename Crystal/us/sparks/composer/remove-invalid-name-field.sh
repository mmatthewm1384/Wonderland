#!/usr/bin/env bash
set -euo pipefail

COMPOSER="$HOME/Wonderland/Crystal/us/sparks/composer/compose.sh"

echo "=== Remove Invalid Lima name Field ==="

cp "$COMPOSER" "$COMPOSER.backup.$(date +%Y%m%d-%H%M%S)"

python3 <<'PY'
from pathlib import Path

p = Path.home() / "Wonderland/Crystal/us/sparks/composer/compose.sh"

s = p.read_text()

s = s.replace(
    '# Wonderland Spark VM Profile\\n\\nname: ${SPARK_NAME}\\n\\n',
    '# Wonderland Spark VM Profile\\n\\n'
)

p.write_text(s)
PY

echo "[PASS] Removed unsupported Lima field"
