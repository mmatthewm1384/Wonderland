#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL="$WL_HOME/bin/wl"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$WL_HOME/.backup/wl-obsidian-route/wl.$STAMP.bak"

mkdir -p "$(dirname "$BACKUP")"

test -f "$WL" || {
  echo "FAIL missing wl: $WL"
  exit 1
}

cp "$WL" "$BACKUP"
echo "BACKUP $BACKUP"

if grep -q 'cmd_obsidian()' "$WL"; then
  echo "PASS obsidian function already present"
else
  cat >> "$WL" <<'EOF_ROUTE'

cmd_obsidian() {
  local obs="$WL_HOME/bin/wl-obsidian"
  if [[ ! -x "$obs" ]]; then
    echo "FAIL missing executable: $obs"
    echo "Run: chmod +x $obs"
    return 1
  fi
  "$obs" "$@"
}
EOF_ROUTE
fi

if grep -q 'obsidian)' "$WL"; then
  echo "PASS obsidian case already present"
else
  python3 - "$WL" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

needle = '  chaos)\n'
insert = '''  obsidian)
    cmd_obsidian "$@"
    ;;

'''

if needle in s:
    s = s.replace(needle, insert + needle, 1)
else:
    needle = '  *)\n'
    if needle not in s:
        raise SystemExit("FAIL could not find case insertion point")
    s = s.replace(needle, insert + needle, 1)

p.write_text(s)
PY
fi

chmod +x "$WL"

echo "VERIFY ROUTE"
"$WL" obsidian status || true
