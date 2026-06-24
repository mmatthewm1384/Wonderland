#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL="$WL_HOME/bin/wl"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$WL_HOME/.backup/wl-obsidian-precase/wl.$STAMP.bak"

mkdir -p "$(dirname "$BACKUP")"
cp "$WL" "$BACKUP"

python3 - "$WL" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

block = '''
# Obsidian operator route
if [[ "${cmd:-}" == "obsidian" ]]; then
  obs="$WL_HOME/bin/wl-obsidian"
  if [[ ! -x "$obs" ]]; then
    echo "FAIL missing executable: $obs"
    exit 1
  fi
  "$obs" "$@"
  exit $?
fi

'''

if '# Obsidian operator route' in s:
    print("PASS obsidian precase already present")
else:
    needle = 'wl_help() {'
    if needle not in s:
        raise SystemExit("FAIL could not find insertion point")
    s = s.replace(needle, block + needle, 1)
    p.write_text(s)
    print("PASS inserted obsidian precase route")
PY

chmod +x "$WL"
"$WL" obsidian status
