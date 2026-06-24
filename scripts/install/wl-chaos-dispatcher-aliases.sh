#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
WL="$ROOT/bin/wl"
EPH="$ROOT/Wonderland-v4/ephemeral/bin"
STAMP="$(date +%Y%m%d-%H%M%S)"

cp "$WL" "$WL.backup.$STAMP"

python3 - "$WL" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

if "WL_CHAOS_EXTENDED_ALIASES" in s:
    print("already patched")
    raise SystemExit(0)

old = '''chaos)
'''
if old not in s:
    raise SystemExit("Could not find chaos dispatcher block")

# Add direct top-level visual-chaos route before final fallback.
marker = '''*)
'''
visual = '''# WL_CHAOS_EXTENDED_ALIASES
visual-chaos)
  shift
  exec "$ROOT/Wonderland-v4/ephemeral/bin/wl-visual-chaos" "$@"
  ;;

'''
if marker in s and "wl-visual-chaos" not in s:
    s = s.replace(marker, visual + marker, 1)

# Extend the existing chaos block by inserting early subcommand handlers after `shift`
s = s.replace(
'''chaos)
  shift
''',
'''chaos)
  shift
  case "${1:-status}" in
    reset)
      shift
      exec "$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-watchdog" reset "$@"
      ;;
    checkin)
      shift
      exec "$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-watchdog" checkin "$@"
      ;;
    countdown)
      shift
      exec "$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-watchdog" countdown "$@"
      ;;
    escalate)
      shift
      exec "$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-watchdog" escalate "$@"
      ;;
  esac
''',
1
)

p.write_text(s)
PY

chmod +x "$WL"
bash -n "$WL"

echo "PASS patched wl dispatcher"
echo "Backup: $WL.backup.$STAMP"
