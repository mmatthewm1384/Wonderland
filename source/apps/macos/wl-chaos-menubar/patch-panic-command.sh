#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Wonderland/apps/macos/wl-chaos-menubar"
SRC="$APP/Sources/wl-chaos-menubar/main.swift"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$APP/backups/main.swift.backup.$STAMP"

mkdir -p "$APP/backups"
cp "$SRC" "$BACKUP"

python3 - "$SRC" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

s = s.replace(
    'let output = shell("\\(chaosBin)/wl-chaos-panic --force \'Menubar Panic\'")',
    'let output = shell("\\(chaosBin)/wl-chaos-panic --yes --reason=menubar-panic")'
)

p.write_text(s)
PY

cd "$APP"
swift build -c release

mkdir -p "$APP/build"
cp "$APP/.build/release/wl-chaos-menubar" "$APP/build/wl-chaos-menubar"
chmod +x "$APP/build/wl-chaos-menubar"

launchctl kickstart -k "gui/$(id -u)/com.wonderland.chaos-menubar" 2>/dev/null || true

echo "backup: $BACKUP"
echo "PASS patched and rebuilt"
grep -n "wl-chaos-panic" "$SRC"
