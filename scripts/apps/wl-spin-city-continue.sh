#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APP="$ROOT/apps/tauri/wl-spin-city"
SRC="$APP/src"
TAURI="$APP/src-tauri"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$ROOT/backups/wl-spin-city-continue-$STAMP"

[[ -d "$APP" ]] || { echo "FAIL missing $APP"; exit 1; }
[[ -d "$TAURI" ]] || { echo "FAIL missing $TAURI"; exit 1; }

mkdir -p "$BACKUP"
[[ -d "$SRC" ]] && cp -a "$SRC" "$BACKUP/src"
mkdir -p "$SRC"

cat > "$SRC/index.html" <<'HTML'
<!doctype html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>wl-spin-city</title>
  <style>
    html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#05070A}
    canvas{display:block;width:100vw;height:100vh}
    #hud{position:fixed;left:22px;top:18px;color:#00E5FF;font:12px ui-monospace,Menlo,monospace;letter-spacing:.12em;text-shadow:0 0 12px #00E5FF;pointer-events:none}
    #hud small{display:block;margin-top:8px;color:#00FF66;opacity:.75}
  </style>
</head>
<body>
  <div id="hud">WL-SPIN-CITY<small>trajectory authority / orbital cognition</small></div>
  <canvas id="scene"></canvas>
  <script type="module" src="./main.js"></script>
</body>
</html>
HTML

cat > "$SRC/main.js" <<'JS'
const canvas = document.getElementById("scene");
const ctx = canvas.getContext("2d");

const C = {
  bg: "#05070A",
  cyan: "#00E5FF",
  purple: "#7000FF",
  green: "#00FF66"
};

let W = 0, H = 0, DPR = 1;

function resize() {
  DPR = Math.max(1, Math.min(2, window.devicePixelRatio || 1));
  W = window.innerWidth;
  H = window.innerHeight;
  canvas.width = Math.floor(W * DPR);
  canvas.height = Math.floor(H * DPR);
  ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
}

window.addEventListener("resize", resize);
resize();

function glow(color, blur) {
  ctx.shadowColor = color;
  ctx.shadowBlur = blur;
}

function clearGlow() {
  ctx.shadowBlur = 0;
}

function trajectoryPoint(cx, cy, t, time) {
  return {
    x: cx + Math.cos(t) * 382 + Math.sin(t * 2.15 + time * 0.19) * 46,
    y: cy + Math.sin(t) * 145 + Math.cos(t * 1.72 - time * 0.16) * 36
  };
}

function ringPoint(cx, cy, rx, ry, t, wobble, phase) {
  const d =
    Math.sin(t * 5 + phase) * wobble +
    Math.sin(t * 9 - phase * 0.7) * wobble * 0.35 +
    Math.cos(t * 3 + phase * 1.4) * wobble * 0.2;

  return {
    x: cx + Math.cos(t) * (rx + d),
    y: cy + Math.sin(t) * (ry + d * 0.52)
  };
}

function drawTrajectory(cx, cy, time) {
  glow(C.cyan, 20);
  ctx.globalAlpha = 0.75;
  ctx.strokeStyle = C.cyan;
  ctx.lineWidth = 2;

  ctx.beginPath();
  for (let i = 0; i <= 460; i++) {
    const p = trajectoryPoint(cx, cy, (i / 460) * Math.PI * 2, time);
    if (i === 0) ctx.moveTo(p.x, p.y);
    else ctx.lineTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  glow(C.purple, 12);
  ctx.globalAlpha = 0.28;
  ctx.strokeStyle = C.purple;
  ctx.lineWidth = 1;

  ctx.beginPath();
  for (let i = 0; i <= 460; i++) {
    const p = trajectoryPoint(cx, cy, (i / 460) * Math.PI * 2 + 0.16, time + 2.7);
    if (i === 0) ctx.moveTo(p.x, p.y);
    else ctx.lineTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  for (let i = 0; i < 4; i++) {
    const p = trajectoryPoint(cx, cy, time * 0.13 + i * 1.57, time);
    glow(C.green, 24);
    ctx.fillStyle = C.green;
    ctx.globalAlpha = 0.86;
    ctx.beginPath();
    ctx.arc(p.x, p.y, 4.5, 0, Math.PI * 2);
    ctx.fill();

    ctx.globalAlpha = 0.18;
    ctx.strokeStyle = C.green;
    ctx.beginPath();
    ctx.arc(p.x, p.y, 17, 0, Math.PI * 2);
    ctx.stroke();
  }

  clearGlow();
  ctx.globalAlpha = 1;
}

function drawChainRing(cx, cy, rx, ry, rotation, color, links, wobble, phase) {
  ctx.save();
  ctx.translate(cx, cy);
  ctx.rotate(rotation);
  ctx.translate(-cx, -cy);

  glow(color, 12);
  ctx.globalAlpha = 0.22;
  ctx.strokeStyle = color;
  ctx.lineWidth = 2;

  ctx.beginPath();
  for (let i = 0; i <= 420; i++) {
    const p = ringPoint(cx, cy, rx, ry, (i / 420) * Math.PI * 2, wobble, phase);
    if (i === 0) ctx.moveTo(p.x, p.y);
    else ctx.lineTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  for (let i = 0; i < links; i++) {
    const t = (i / links) * Math.PI * 2;
    const p = ringPoint(cx, cy, rx, ry, t, wobble, phase);
    const n = ringPoint(cx, cy, rx, ry, t + 0.035, wobble, phase);
    const a = Math.atan2(n.y - p.y, n.x - p.x);

    ctx.save();
    ctx.translate(p.x, p.y);
    ctx.rotate(a);

    glow(color, 10);
    ctx.globalAlpha = 0.82;
    ctx.strokeStyle = color;
    ctx.lineWidth = 1.5;
    ctx.strokeRect(-10, -4, 20, 8);

    ctx.globalAlpha = 0.25;
    ctx.fillStyle = color;
    ctx.fillRect(-7, -2, 14, 4);
    ctx.restore();
  }

  ctx.restore();
  clearGlow();
  ctx.globalAlpha = 1;
}

function rotated(cx, cy, x, y, r) {
  const dx = x - cx;
  const dy = y - cy;
  return {
    x: cx + Math.cos(r) * dx - Math.sin(r) * dy,
    y: cy + Math.sin(r) * dx + Math.cos(r) * dy
  };
}

function drawHook(x, y, angle, color, pulse) {
  ctx.save();
  ctx.translate(x, y);
  ctx.rotate(angle);

  glow(color, 12 + pulse * 18);
  ctx.strokeStyle = color;
  ctx.lineWidth = 2 + pulse;
  ctx.globalAlpha = 0.72 + pulse * 0.25;

  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(15, 0);
  ctx.arc(24, 8, 10, -Math.PI * 0.75, Math.PI * 0.92);
  ctx.stroke();

  ctx.globalAlpha = 0.28 + pulse * 0.22;
  ctx.beginPath();
  ctx.arc(0, 0, 4 + pulse * 5, 0, Math.PI * 2);
  ctx.stroke();

  ctx.restore();
  clearGlow();
  ctx.globalAlpha = 1;
}

function drawHooks(cx, cy, rx, ry, rotation, color, time) {
  const positions = [0.09, 0.24, 0.43, 0.61, 0.79];

  for (const h of positions) {
    const t = h * Math.PI * 2;
    const p = ringPoint(cx, cy, rx, ry, t, 18, time * 0.3);
    const n = ringPoint(cx, cy, rx, ry, t + 0.04, 18, time * 0.3);
    const rp = rotated(cx, cy, p.x, p.y, rotation);
    const pulse = Math.max(0, Math.sin(time * 1.6 + h * 18)) ** 6;
    const angle = Math.atan2(n.y - p.y, n.x - p.x) + rotation + Math.PI * 0.5;

    drawHook(rp.x, rp.y, angle, color, pulse);
  }
}

function drawWatchers(cx, cy, time) {
  const positions = [0.13, 0.37, 0.59, 0.82];

  for (const pos of positions) {
    const p = trajectoryPoint(cx, cy, pos * Math.PI * 2 + Math.sin(time * 0.08) * 0.15, time);
    const dist = 58 + Math.sin(time * 0.25 + pos * 20) * 10;
    const x = p.x + Math.cos(pos * 12) * dist;
    const y = p.y + Math.sin(pos * 12) * dist;

    glow(C.green, 12);
    ctx.strokeStyle = C.green;
    ctx.lineWidth = 1.5;
    ctx.globalAlpha = 0.58;

    ctx.beginPath();
    ctx.arc(x, y, 7, 0, Math.PI * 2);
    ctx.stroke();

    ctx.globalAlpha = 0.20;
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(p.x, p.y);
    ctx.stroke();
  }

  clearGlow();
  ctx.globalAlpha = 1;
}

function drawGhosts(cx, cy, time) {
  for (let i = 0; i < 8; i++) {
    const p = trajectoryPoint(cx, cy, time * 0.08 + i * 0.75, time);
    const e = 32 + Math.sin(time * 0.7 + i) * 22;

    glow(C.purple, 10);
    ctx.fillStyle = C.purple;
    ctx.globalAlpha = 0.10 + Math.max(0, Math.sin(time * 0.6 + i)) * 0.08;

    ctx.beginPath();
    ctx.arc(
      p.x + Math.cos(i * 2.4) * e,
      p.y + Math.sin(i * 1.9) * e,
      2.6,
      0,
      Math.PI * 2
    );
    ctx.fill();
  }

  clearGlow();
  ctx.globalAlpha = 1;
}

function drawCore(cx, cy, time) {
  glow(C.purple, 22);
  ctx.strokeStyle = C.purple;
  ctx.lineWidth = 2;
  ctx.globalAlpha = 0.72;

  for (let i = 0; i < 4; i++) {
    ctx.beginPath();
    ctx.arc(cx, cy, 24 + i * 14 + Math.sin(time + i) * 2, 0, Math.PI * 2);
    ctx.stroke();
  }

  glow(C.cyan, 20);
  ctx.fillStyle = C.cyan;
  ctx.globalAlpha = 0.95;
  ctx.beginPath();
  ctx.arc(cx, cy, 5, 0, Math.PI * 2);
  ctx.fill();

  clearGlow();
  ctx.globalAlpha = 1;
}

function frame(ms) {
  const time = ms / 1000;
  const cx = W / 2;
  const cy = H / 2 + 20;

  ctx.fillStyle = C.bg;
  ctx.fillRect(0, 0, W, H);

  drawTrajectory(cx, cy, time);
  drawGhosts(cx, cy, time);

  const slow = time * 0.155;

  drawChainRing(cx, cy, 330, 112, slow, C.cyan, 58, 22, time * 0.42);
  drawChainRing(cx, cy, 252, 194, -slow * 0.86, C.purple, 48, 18, -time * 0.36);
  drawChainRing(cx, cy, 415, 64, -slow * 0.5 + 0.55, C.green, 70, 12, time * 0.25);

  drawHooks(cx, cy, 330, 112, slow, C.cyan, time);
  drawHooks(cx, cy, 252, 194, -slow * 0.86, C.purple, time);

  drawWatchers(cx, cy, time);
  drawCore(cx, cy, time);

  requestAnimationFrame(frame);
}

requestAnimationFrame(frame);
JS

echo
echo "VERIFY frontendDist:"
if grep -R '"frontendDist"[[:space:]]*:[[:space:]]*"../src"' "$TAURI"/tauri.conf.* >/dev/null 2>&1; then
  echo "PASS frontendDist ../src"
else
  echo "WARN frontendDist not found as ../src"
  grep -R "frontendDist" "$TAURI"/tauri.conf.* 2>/dev/null || true
fi

echo
echo "VERIFY files:"
ls -la "$SRC/index.html" "$SRC/main.js"

echo
echo "PASS wl-spin-city continue installed"
echo "Backup: $BACKUP"
echo
echo "Run:"
echo "  cd $APP"
echo "  npm run tauri dev"
