#!/usr/bin/env bash
set -euo pipefail

APP="${WL_ROOT:-$HOME/Wonderland}/apps/tauri/wl-spin-city"
SRC="$APP/src/main.js"
BACKUP="${WL_ROOT:-$HOME/Wonderland}/backups/wl-spin-city-no-chains-$(date +%Y%m%d-%H%M%S)"

[[ -f "$SRC" ]] || { echo "FAIL missing $SRC"; exit 1; }

mkdir -p "$BACKUP"
cp -a "$APP/src" "$BACKUP/src"

python3 - "$SRC" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

start = s.index("function drawRing(")
end = s.index("\nfunction pulseNear", start)

replacement = r'''
function drawRing(cx, cy, rx, ry, rot, color, links, phase, wobble, alpha) {
  ctx.save();
  ctx.translate(cx, cy);
  ctx.rotate(rot);
  ctx.translate(-cx, -cy);

  // living primary current
  glow(color, 18);
  ctx.strokeStyle = color;
  ctx.lineWidth = 2.2;
  ctx.globalAlpha = alpha * 0.62;

  ctx.beginPath();
  for (let i = 0; i <= 720; i++) {
    const p = ringPoint(cx, cy, rx, ry, (i / 720) * Math.PI * 2, phase, wobble);
    i ? ctx.lineTo(p.x, p.y) : ctx.moveTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  // inner echo current
  ctx.strokeStyle = color;
  ctx.lineWidth = 1;
  ctx.globalAlpha = alpha * 0.22;

  ctx.beginPath();
  for (let i = 0; i <= 720; i++) {
    const t = (i / 720) * Math.PI * 2;
    const p = ringPoint(cx, cy, rx * 0.965, ry * 0.965, t, phase + 1.7, wobble * 0.58);
    i ? ctx.lineTo(p.x, p.y) : ctx.moveTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  // outer spectral halo
  ctx.lineWidth = 0.75;
  ctx.globalAlpha = alpha * 0.14;

  ctx.beginPath();
  for (let i = 0; i <= 720; i++) {
    const t = (i / 720) * Math.PI * 2;
    const p = ringPoint(cx, cy, rx * 1.035, ry * 1.035, t, phase - 1.1, wobble * 0.72);
    i ? ctx.lineTo(p.x, p.y) : ctx.moveTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  ctx.restore();
  clearGlow();
  ctx.globalAlpha = 1;
}
'''

s = s[:start] + replacement + s[end:]

p.write_text(s)
PY

echo "PASS removed chains; restored continuous living rings"
echo "Backup: $BACKUP"
echo
echo "Run:"
echo "  cd $APP && npm run tauri dev"
