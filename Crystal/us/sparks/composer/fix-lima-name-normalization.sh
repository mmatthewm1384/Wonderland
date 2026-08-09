#!/usr/bin/env bash
set -euo pipefail

COMPOSER="$HOME/Wonderland/Crystal/us/sparks/composer/compose.sh"

echo "=== Spark Lima Name Normalization Fix ==="

cp "$COMPOSER" "$COMPOSER.backup.$(date +%Y%m%d-%H%M%S)"

python3 <<'PY'
from pathlib import Path

p = Path.home() / "Wonderland/Crystal/us/sparks/composer/compose.sh"

s = p.read_text()

# Ensure output name has no .lima suffix
s = s.replace(
    'OUTPUT="$SPARK_DIR/${SPARK_NAME}.lima.yaml"',
    'OUTPUT="$SPARK_DIR/${SPARK_NAME}.yaml"'
)

# Add lima instance name if absent
if "name:" not in s:
    s = s.replace(
        "# Wonderland Spark VM Profile",
        "# Wonderland Spark VM Profile\\n\\nname: ${SPARK_NAME}"
    )

p.write_text(s)
PY

echo "[PASS] Composer normalized"
