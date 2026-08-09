#!/usr/bin/env bash
set -euo pipefail

echo "=== Spark Primary Runtime Disk Fix ==="

COMPOSE="$HOME/Wonderland/Crystal/us/sparks/composer/compose.sh"

python3 - "$COMPOSE" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
t = p.read_text()

# Remove additionalDisks block
start = t.find("additionalDisks:")
if start != -1:
    end = t.find("\n\nmounts:", start)
    if end != -1:
        t = t[:start] + t[end+2:]

# Replace ISO image with runtime disk
t = t.replace(
    'location: https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/aarch64/alpine-virt-3.20.3-aarch64.iso',
    'location: "$RUNTIME_DISK"'
)

# Remove mounts if present
t = t.replace(
'''mounts:
  - location: "$RUNTIME_DISK"
    mountPoint: /mnt/spark-runtime
''',
'''mounts: []
'''
)

p.write_text(t)
PY

echo "[PASS] Spark now uses runtime disk as primary disk"
