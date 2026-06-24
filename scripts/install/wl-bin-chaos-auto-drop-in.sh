#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
WL="$ROOT/bin/wl"
EPH="$ROOT/Wonderland-v4/ephemeral/bin"
GOV="$ROOT/Wonderland-v4/governance/verify-chaos.py"

mkdir -p "$ROOT/bin"

if [[ ! -f "$WL" ]]; then
  cat > "$WL" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"

case "${1:-}" in
  *)
    echo "Usage: wl <command>"
    exit 2
    ;;
esac
SH
fi

BACKUP="$WL.backup.$(date +%Y%m%d-%H%M%S)"
cp "$WL" "$BACKUP"

python3 - "$WL" <<'PY'
from pathlib import Path
import sys

wl = Path(sys.argv[1])
s = wl.read_text()

routes = r'''
  ephemeral)
    shift
    exec "$ROOT/Wonderland-v4/ephemeral/bin/wl-ephemeral" "$@"
    ;;

  chaos|chaos-watchdog)
    shift
    exec "$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-watchdog" "$@"
    ;;

  chaos-panic)
    shift
    exec "$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-panic" "$@"
    ;;

  skhd-permissions)
    shift
    exec "$ROOT/Wonderland-v4/ephemeral/bin/wl-skhd-permissions" "$@"
    ;;

  visual-chaos)
    shift
    exec "$ROOT/Wonderland-v4/ephemeral/bin/wl-visual-chaos" "$@"
    ;;
'''

gov_route = r'''
  governance)
    shift
    case "${1:-}" in
      verify-chaos)
        shift
        exec python3 "$ROOT/Wonderland-v4/governance/verify-chaos.py" "$@"
        ;;
      *)
        echo "Usage: wl governance verify-chaos"
        exit 2
        ;;
    esac
    ;;
'''

if "wl-chaos-watchdog" not in s:
    marker = 'case "${1:-}" in'
    if marker not in s:
        raise SystemExit("FAIL: bin/wl does not contain a recognizable case dispatcher")
    s = s.replace(marker, marker + routes, 1)

if "verify-chaos.py" not in s:
    marker = 'case "${1:-}" in'
    if marker not in s:
        raise SystemExit("FAIL: bin/wl does not contain a recognizable case dispatcher")
    s = s.replace(marker, marker + gov_route, 1)

wl.write_text(s)
PY

chmod +x "$WL"

echo "PASS patched: $WL"
echo "Backup: $BACKUP"
echo
echo "Verify:"
echo "  wl ephemeral doctor"
echo "  wl chaos doctor"
echo "  wl chaos status"
echo "  wl visual-chaos status"
echo "  wl governance verify-chaos"
