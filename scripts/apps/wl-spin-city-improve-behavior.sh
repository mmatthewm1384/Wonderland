#!/usr/bin/env bash
set -euo pipefail

APP="${WL_ROOT:-$HOME/Wonderland}/apps/tauri/wl-spin-city"
SRC="$APP/src/main.js"
BACKUP="${WL_ROOT:-$HOME/Wonderland}/backups/wl-spin-city-improve-$(date +%Y%m%d-%H%M%S)"

[[ -f "$SRC" ]] || { echo "FAIL missing $SRC"; exit 1; }

mkdir -p "$BACKUP"
cp -a "$APP/src" "$BACKUP/src"

python3 - "$SRC" <<'PY'
from pathlib import Path
p = Path(__import__("sys").argv[1])
s = p.read_text()

insert = r'''

function dist(a, b) {
  return Math.hypot(a.x - b.x, a.y - b.y);
}

function attentionCarrierPoints(cx, cy, time) {
  return [0, 1, 2, 3].map(i =>
    trajectoryPoint(cx, cy, time * 0.13 + i * 1.57, time)
  );
}

function hookPulseFromTrajectory(x, y, cx, cy, time) {
  const carriers = attentionCarrierPoints(cx, cy, time);
  let nearest = 9999;
  for (const c of carriers) nearest = Math.min(nearest, Math.hypot(c.x - x, c.y - y));
  return Math.max(0, 1 - nearest / 95) ** 3;
}

function drawCollapseGlyph(cx, cy, time) {
  const cycle = Math.max(0, Math.sin(time * 0.42)) ** 10;
  if (cycle <= 0.01) return;

  const p = trajectoryPoint(cx, cy, time * 0.13 + 1.57, time);

  glow(C.purple, 28 + cycle * 22);
  ctx.strokeStyle = C.purple;
  ctx.lineWidth = 1.5 + cycle * 1.5;
  ctx.globalAlpha = 0.18 + cycle * 0.62;

  ctx.save();
  ctx.translate(p.x, p.y);
  ctx.rotate(time * 0.15);

  ctx.beginPath();
  for (let i = 0; i < 6; i++) {
    const a = (i / 6) * Math.PI * 2;
    const r = 24 + cycle * 42;
    const x = Math.cos(a) * r;
    const y = Math.sin(a) * r;
    if (i === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  }
  ctx.closePath();
  ctx.stroke();

  ctx.beginPath();
  ctx.arc(0, 0, 8 + cycle * 16, 0, Math.PI * 2);
  ctx.stroke();

  ctx.restore();
  clearGlow();
  ctx.globalAlpha = 1;
}
'''

if "function dist(a, b)" not in s:
    s = s.replace("function frame(ms) {", insert + "\nfunction frame(ms) {")

s = s.replace(
'''    const pulse = Math.max(0, Math.sin(time * 1.6 + h * 18)) ** 6;
    const angle = Math.atan2(n.y - p.y, n.x - p.x) + rotation + Math.PI * 0.5;

    drawHook(rp.x, rp.y, angle, color, pulse);''',
'''    const pulse = hookPulseFromTrajectory(rp.x, rp.y, cx, cy, time);
    const angle = Math.atan2(n.y - p.y, n.x - p.x) + rotation + Math.PI * 0.5;

    drawHook(rp.x, rp.y, angle, color, pulse);'''
)

s = s.replace(
'''  drawWatchers(cx, cy, time);
  drawCore(cx, cy, time);''',
'''  drawWatchers(cx, cy, time);
  drawCollapseGlyph(cx, cy, time);
  drawCore(cx, cy, time);'''
)

p.write_text(s)
PY

echo "PASS improved wl-spin-city behavior"
echo "Backup: $BACKUP"
echo
echo "Run:"
echo "  cd $APP && npm run tauri dev"
