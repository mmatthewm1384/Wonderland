#!/usr/bin/env bash
set -euo pipefail

APP="${WL_ROOT:-$HOME/Wonderland}/apps/tauri/wl-spin-city"
SRC="$APP/src/main.js"
BACKUP="${WL_ROOT:-$HOME/Wonderland}/backups/wl-spin-city-improve-2-$(date +%Y%m%d-%H%M%S)"

[[ -f "$SRC" ]] || { echo "FAIL missing $SRC"; exit 1; }

mkdir -p "$BACKUP"
cp -a "$APP/src" "$BACKUP/src"

python3 - "$SRC" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

s = s.replace(
'''function hookPulseFromTrajectory(x, y, cx, cy, time) {
  const carriers = attentionCarrierPoints(cx, cy, time);
  let nearest = 9999;
  for (const c of carriers) nearest = Math.min(nearest, Math.hypot(c.x - x, c.y - y));
  return Math.max(0, 1 - nearest / 95) ** 3;
}''',
'''function hookPulseFromTrajectory(x, y, cx, cy, time) {
  const carriers = attentionCarrierPoints(cx, cy, time);
  let nearest = 9999;
  for (const c of carriers) nearest = Math.min(nearest, Math.hypot(c.x - x, c.y - y));
  return Math.max(0, 1 - nearest / 115) ** 4;
}

function drawTrajectoryCrossing(x, y, pulse, color) {
  if (pulse < 0.035) return;

  glow(color, 30 * pulse);
  ctx.strokeStyle = color;
  ctx.lineWidth = 1 + pulse * 2;
  ctx.globalAlpha = 0.16 + pulse * 0.5;

  ctx.beginPath();
  ctx.arc(x, y, 18 + pulse * 42, 0, Math.PI * 2);
  ctx.stroke();

  ctx.beginPath();
  ctx.moveTo(x - 34 * pulse, y);
  ctx.lineTo(x + 34 * pulse, y);
  ctx.moveTo(x, y - 34 * pulse);
  ctx.lineTo(x, y + 34 * pulse);
  ctx.stroke();

  clearGlow();
  ctx.globalAlpha = 1;
}

function collapseStrength(cx, cy, time) {
  const carriers = attentionCarrierPoints(cx, cy, time);
  const watchers = [0.13, 0.37, 0.59, 0.82].map(pos =>
    trajectoryPoint(cx, cy, pos * Math.PI * 2 + Math.sin(time * 0.08) * 0.15, time)
  );

  let strength = 0;
  for (const c of carriers) {
    for (const w of watchers) {
      strength += Math.max(0, 1 - Math.hypot(c.x - w.x, c.y - w.y) / 280);
    }
  }

  return Math.min(1, Math.max(0, strength / 3.2));
}'''
)

s = s.replace(
'''    drawHook(rp.x, rp.y, angle, color, pulse);''',
'''    drawHook(rp.x, rp.y, angle, color, pulse);
    drawTrajectoryCrossing(rp.x, rp.y, pulse, color);'''
)

s = s.replace(
'''function drawCollapseGlyph(cx, cy, time) {
  const cycle = Math.max(0, Math.sin(time * 0.42)) ** 10;
  if (cycle <= 0.01) return;

  const p = trajectoryPoint(cx, cy, time * 0.13 + 1.57, time);''',
'''function drawCollapseGlyph(cx, cy, time) {
  const cycle = collapseStrength(cx, cy, time);
  if (cycle <= 0.24) return;

  const p = trajectoryPoint(cx, cy, time * 0.13 + 1.57, time);'''
)

s = s.replace(
'''    ctx.globalAlpha = 0.20;
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(p.x, p.y);
    ctx.stroke();''',
'''    ctx.globalAlpha = 0.20;
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(p.x, p.y);
    ctx.stroke();

    ctx.globalAlpha = 0.38;
    ctx.beginPath();
    ctx.moveTo(x - 10, y);
    ctx.lineTo(x + 10, y);
    ctx.moveTo(x, y - 10);
    ctx.lineTo(x, y + 10);
    ctx.stroke();'''
)

s = s.replace(
'''      2.6,
      0,
      Math.PI * 2
    );
    ctx.fill();''',
'''      2.6,
      0,
      Math.PI * 2
    );
    ctx.fill();

    ctx.globalAlpha *= 0.45;
    ctx.strokeStyle = C.purple;
    ctx.beginPath();
    ctx.moveTo(p.x, p.y);
    ctx.lineTo(
      p.x + Math.cos(i * 2.4) * e,
      p.y + Math.sin(i * 1.9) * e
    );
    ctx.stroke();'''
)

p.write_text(s)
PY

echo "PASS wl-spin-city improve pass 2"
echo "Backup: $BACKUP"
echo
echo "Run:"
echo "  cd $APP && npm run tauri dev"
