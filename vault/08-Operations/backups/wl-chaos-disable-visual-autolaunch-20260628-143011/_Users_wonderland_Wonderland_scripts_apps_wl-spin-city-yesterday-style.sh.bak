#!/usr/bin/env bash
set -euo pipefail

APP="${WL_ROOT:-$HOME/Wonderland}/apps/tauri/wl-spin-city"
SRC="$APP/src/main.js"
BACKUP="${WL_ROOT:-$HOME/Wonderland}/backups/wl-spin-city-yesterday-style-$(date +%Y%m%d-%H%M%S)"

[[ -f "$SRC" ]] || { echo "FAIL missing $SRC"; exit 1; }

mkdir -p "$BACKUP"
cp -a "$APP/src" "$BACKUP/src"

python3 - "$SRC" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

s = s.replace("watcherCount: 4,", "watcherCount: 3,")
s = s.replace("ghostCount: 8,", "ghostCount: 5,")
s = s.replace("trajectoryCarrierCount: 4,", "trajectoryCarrierCount: 3,")
s = s.replace("speed: 0.145,", "speed: 0.092,")
s = s.replace("collapseThreshold: 0.24", "collapseThreshold: 0.38")

s = s.replace(
"ctx.globalAlpha = 0.74;\n  ctx.strokeStyle = C.cyan;\n  ctx.lineWidth = 2;",
"ctx.globalAlpha = 0.46;\n  ctx.strokeStyle = C.cyan;\n  ctx.lineWidth = 1.35;"
)

s = s.replace(
"ctx.globalAlpha = 0.28;\n  ctx.strokeStyle = C.purple;\n  ctx.lineWidth = 1;",
"ctx.globalAlpha = 0.18;\n  ctx.strokeStyle = C.purple;\n  ctx.lineWidth = 0.8;"
)

s = s.replace(
"ctx.arc(p.x, p.y, 4.5, 0, Math.PI * 2);",
"ctx.arc(p.x, p.y, 3.2, 0, Math.PI * 2);"
)

s = s.replace(
"ctx.arc(p.x, p.y, 17, 0, Math.PI * 2);",
"ctx.arc(p.x, p.y, 11, 0, Math.PI * 2);"
)

s = s.replace(
"const positions = [0.09, 0.24, 0.43, 0.61, 0.79];",
"const positions = [0.07, 0.28, 0.53, 0.76];"
)

s = s.replace(
"const positions = [0.13, 0.37, 0.59, 0.82];",
"const positions = [0.18, 0.51, 0.81];"
)

s = s.replace(
"const positions = [0.13, 0.37, 0.59, 0.82];",
"const positions = [0.18, 0.51, 0.81];"
)

s = s.replace(
"const dist = 58 + Math.sin(time * 0.25 + pos * 20) * 10;",
"const dist = 82 + Math.sin(time * 0.18 + pos * 20) * 14;"
)

s = s.replace(
"ctx.arc(x, y, 7, 0, Math.PI * 2);",
"ctx.arc(x, y, 5.5, 0, Math.PI * 2);"
)

s = s.replace(
"drawChainRing(cx, cy, 330, 112, slow, C.cyan, 58, 22, time * 0.42);",
"drawChainRing(cx, cy, 360, 122, slow, C.cyan, 64, 30, time * 0.28);"
)

s = s.replace(
"drawChainRing(cx, cy, 252, 194, -slow * 0.86, C.purple, 48, 18, -time * 0.36);",
"drawChainRing(cx, cy, 268, 214, -slow * 0.74, C.purple, 52, 24, -time * 0.24);"
)

s = s.replace(
"drawChainRing(cx, cy, 415, 64, -slow * 0.5 + 0.55, C.green, 70, 12, time * 0.25);",
"drawChainRing(cx, cy, 430, 78, -slow * 0.42 + 0.55, C.green, 72, 16, time * 0.18);"
)

s = s.replace(
"drawHooks(cx, cy, 330, 112, slow, C.cyan, time);",
"drawHooks(cx, cy, 360, 122, slow, C.cyan, time);"
)

s = s.replace(
"drawHooks(cx, cy, 252, 194, -slow * 0.86, C.purple, time);",
"drawHooks(cx, cy, 268, 214, -slow * 0.74, C.purple, time);"
)

p.write_text(s)
PY

echo "PASS restored yesterday-style wl-spin-city"
echo "Backup: $BACKUP"
echo
echo "Run:"
echo "  cd $APP && npm run tauri dev"
