#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL="$WL_HOME/bin/wl"
DATE="$(date +%Y%m%d-%H%M%S)"
BACKUP="$WL_HOME/backups/wl-dispatcher-nav-patch-$DATE"

mkdir -p "$BACKUP"

cp "$WL" "$BACKUP/wl.bak"

python3 - <<'PY'
from pathlib import Path

wl_home = Path.home() / "Wonderland"
p = wl_home / "bin" / "wl"
s = p.read_text()

nav_block = r'''
  nav)
    shift
    exec "$WL_HOME/bin/wl-nav" "$@"
    ;;

  inspect)
    shift
    exec "$WL_HOME/bin/wl-inspect" "$@"
    ;;

  tree)
    shift
    exec "$WL_HOME/bin/wl-tree" "$@"
    ;;
'''

if 'exec "$WL_HOME/bin/wl-nav"' not in s:
    if '  path)' in s:
        s = s.replace('  path)\n', nav_block + '\n  path)\n', 1)
    elif '  *)' in s:
        s = s.replace('  *)\n', nav_block + '\n  *)\n', 1)
    else:
        raise SystemExit("Could not find case insertion point in wl dispatcher")

help_old = '''  wl path
  wl logs
  wl version'''
help_new = '''  wl nav [governance|theomatrix|services|assets|reports]
  wl inspect [path]
  wl tree [path]
  wl path
  wl logs
  wl version'''

if 'wl nav [governance|theomatrix|services|assets|reports]' not in s:
    s = s.replace(help_old, help_new)

p.write_text(s)
PY

chmod +x "$WL"

echo "PASS wl-dispatcher-patched"
echo "backup: $BACKUP"
echo

"$WL" nav
