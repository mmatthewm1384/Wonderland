#!/usr/bin/env bash
set -euo pipefail

echo "=== Spark Runtime Disk Attachment Fix ==="

COMPOSER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

SPARK_DIR="$WL_ROOT/Crystal/us/sparks"
COMPOSE="$COMPOSER_DIR/compose.sh"

if [[ ! -f "$COMPOSE" ]]; then
    echo "[FAIL] Missing composer: $COMPOSE"
    exit 1
fi

python3 - "$COMPOSE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

old = '''mounts:
  - location: "$RUNTIME_DISK"
    mountPoint: /mnt/spark-runtime
'''

new = '''additionalDisks:
  - name: spark-runtime
    path: "$RUNTIME_DISK"

mounts: []
'''

if old in text:
    text = text.replace(old, new)

elif "additionalDisks:" not in text:
    marker = "images:\n"
    idx = text.find(marker)

    if idx == -1:
        raise SystemExit("[FAIL] Could not find images section")

    end = text.find("\n\n", idx)

    if end == -1:
        raise SystemExit("[FAIL] Could not locate images block")

    insert = '''
additionalDisks:
  - name: spark-runtime
    path: "$RUNTIME_DISK"

mounts: []
'''

    text = text[:end] + insert + text[end:]

path.write_text(text)
PY

chmod +x "$COMPOSE"

echo "[PASS] Spark runtime disk attachment fixed"
echo
echo "Regenerate:"
echo "  $COMPOSE spark-matthew-001"
