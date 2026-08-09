#!/usr/bin/env bash
set -euo pipefail

COMPOSE="$HOME/Wonderland/Crystal/us/sparks/composer/compose.sh"

echo "=== Spark Composer Runtime Reference Fix ==="

if [[ ! -f "$COMPOSE" ]]; then
    echo "[FAIL] Missing:"
    echo "$COMPOSE"
    exit 1
fi

cp "$COMPOSE" "$COMPOSE.backup-$(date +%Y%m%d-%H%M%S)"

python3 <<'PY'
from pathlib import Path

p = Path.home() / "Wonderland/Crystal/us/sparks/composer/compose.sh"

s = p.read_text()

# Remove old image/rootfs ownership
s = s.replace(
'''IMAGE_DIR="$SPARK_DIR/images/alpine-spark-v1"
ARTIFACT_DIR="$IMAGE_DIR/artifacts"

ROOTFS="$ARTIFACT_DIR/alpine-spark-rootfs-v1-aarch64.ext4.img"
''',
'''RUNTIME_DIR="$SPARK_DIR/runtime"

RUNTIME_DISK="$RUNTIME_DIR/${SPARK_NAME}-disk.img"
'''
)

# Replace rootfs validation
s = s.replace(
'''if [[ ! -f "$ROOTFS" ]]; then
    echo "[FAIL] Missing rootfs:"
    echo "$ROOTFS"
    exit 1
fi
''',
'''if [[ ! -f "$RUNTIME_DISK" ]]; then
    echo "[FAIL] Missing Spark runtime disk:"
    echo "$RUNTIME_DISK"
    exit 1
fi
'''
)

# Replace generated YAML references
s = s.replace(
'location: "$ROOTFS"',
'location: "$RUNTIME_DISK"'
)

p.write_text(s)

PY

chmod +x "$COMPOSE"

echo "[PASS] compose.sh updated"

grep -n "ROOTFS\|RUNTIME_DISK\|images:" "$COMPOSE" || true
