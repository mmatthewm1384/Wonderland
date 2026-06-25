#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL="$WL_HOME/bin/wl"
DATE="$(date +%Y%m%d-%H%M%S)"
BACKUP="$WL_HOME/backups/wl-nav-dispatch-repair-$DATE"

mkdir -p "$BACKUP"
cp "$WL" "$BACKUP/wl.bak"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("${WL_AUTHORITY_ROOT:-${WL_HOME:-$HOME/Wonderland}}/bin/wl")
s = p.read_text()

# Remove bad block if it was inserted inside wl_services or another function.
bad = re.compile(
r'''
\n\s+nav\)
\s+shift
\s+exec "\$WL_HOME/bin/wl-nav" "\$@"
\s+;;
\n
\s+inspect\)
\s+shift
\s+exec "\$WL_HOME/bin/wl-inspect" "\$@"
\s+;;
\n
\s+tree\)
\s+shift
\s+exec "\$WL_HOME/bin/wl-tree" "\$@"
\s+;;
''',
re.VERBOSE
)
s = bad.sub("\n", s)

route = r'''
# Wonderland navigator early routes
case "${cmd:-}" in
  nav)
    exec "$WL_HOME/bin/wl-nav" "$@"
    ;;
  inspect)
    exec "$WL_HOME/bin/wl-inspect" "$@"
    ;;
  tree)
    exec "$WL_HOME/bin/wl-tree" "$@"
    ;;
esac

'''

if '# Wonderland navigator early routes' not in s:
    marker = 'shift || true\n\n'
    if marker not in s:
        raise SystemExit("Could not find insertion point after shift")
    s = s.replace(marker, marker + route, 1)

p.write_text(s)
PY

chmod +x "$WL"

echo "PASS repaired-wl-nav-dispatch"
echo "backup: $BACKUP"
echo

"$WL" nav
