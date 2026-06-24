#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL="$WL_HOME/bin/wl"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$WL_HOME/.backup/wl-clean-obsidian-route/wl.$STAMP.bak"

mkdir -p "$(dirname "$BACKUP")"
cp "$WL" "$BACKUP"

python3 - "$WL" <<'PY'
from pathlib import Path
import re, sys

p = Path(sys.argv[1])
s = p.read_text()

# Remove misplaced case block if present.
s = re.sub(
    r'\n\s*obsidian\)\n\s*cmd_obsidian "\$@"\n\s*;;\n',
    '\n',
    s,
    count=1
)

# Remove appended cmd_obsidian function if present.
s = re.sub(
    r'\ncmd_obsidian\(\) \{\n(?:.*\n)*?\}\n?$',
    '\n',
    s,
    count=1
)

p.write_text(s)
PY

chmod +x "$WL"

echo "=== obsidian route ==="
grep -n "Obsidian operator route" "$WL"

echo
echo "=== verify ==="
"$WL" obsidian status
"$WL" obsidian verify
