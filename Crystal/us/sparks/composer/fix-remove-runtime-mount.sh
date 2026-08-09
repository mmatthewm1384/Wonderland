#!/usr/bin/env bash
set -euo pipefail

COMPOSE="$HOME/Wonderland/Crystal/us/sparks/composer/compose.sh"

cp "$COMPOSE" "$COMPOSE.backup-mount-fix-$(date +%Y%m%d-%H%M%S)"

python3 <<'PY'
from pathlib import Path

p = Path.home() / "Wonderland/Crystal/us/sparks/composer/compose.sh"

s = p.read_text()

s = s.replace(
'''mounts:
  - location: "$RUNTIME_DISK"
''',
'''mounts: []
'''
)

p.write_text(s)
PY

echo "[PASS] Removed runtime disk mount"
