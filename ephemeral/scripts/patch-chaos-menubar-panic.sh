#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
EPH="$WL_HOME/ephemeral"
MENUBAR="$EPH/bin/wl-chaos-menubar"
PANIC="$EPH/bin/wl-chaos-panic"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$MENUBAR.backup.$STAMP"

echo "== chaos menubar panic patch =="

test -x "$PANIC" || {
  echo "FAIL missing executable panic command: $PANIC"
  exit 1
}

test -f "$MENUBAR" || {
  echo "FAIL missing menubar: $MENUBAR"
  exit 1
}

cp "$MENUBAR" "$BACKUP"
echo "backup: $BACKUP"

python3 - "$MENUBAR" "$PANIC" <<'PY'
from pathlib import Path
import sys

menubar = Path(sys.argv[1])
panic = sys.argv[2]
text = menubar.read_text()

if "wl-chaos-panic" in text and "menubar-panic" in text:
    print("PASS already patched")
    raise SystemExit(0)

if "import subprocess" not in text:
    text = text.replace("import os\n", "import os\nimport subprocess\n", 1) if "import os\n" in text else "import subprocess\n" + text

panic_func = f'''

def wl_panic_action(_=None):
    subprocess.Popen([
        "{panic}",
        "--yes",
        "--reason=menubar-panic"
    ])
'''

if "def wl_panic_action" not in text:
    text += panic_func

# rumps-style menu patch
if "rumps.MenuItem" in text:
    if '"Panic"' not in text and "'Panic'" not in text:
        text = text.replace(
            "app.menu = [",
            'app.menu = [\\n        rumps.MenuItem("Panic", callback=wl_panic_action),',
            1
        )
    else:
        text = text.replace(
            'rumps.MenuItem("Panic")',
            'rumps.MenuItem("Panic", callback=wl_panic_action)'
        ).replace(
            "rumps.MenuItem('Panic')",
            "rumps.MenuItem('Panic', callback=wl_panic_action)"
        )

# fallback: if no recognizable menu structure, append explicit note and fail
if "wl_panic_action" not in text or "menubar-panic" not in text:
    raise SystemExit("FAIL could not patch menubar automatically")

menubar.write_text(text)
print("PASS patched menubar panic action")
PY

chmod +x "$MENUBAR"

launchctl kickstart -k "gui/$(id -u)/com.wonderland.chaos-menubar" 2>/dev/null || true

echo
echo "== verify =="
grep -n "wl-chaos-panic\|menubar-panic\|wl_panic_action\|Panic" "$MENUBAR" || true
echo
echo "Click Panic, then run:"
echo "tail -10 $WL_HOME/vault/chaos/panic.log"
