#!/usr/bin/env bash
set -euo pipefail

APP="${WL_ROOT:-$HOME/Wonderland}/apps/tauri/wl-spin-city"
SRC="$APP/src"
BACKUP="${WL_ROOT:-$HOME/Wonderland}/backups/wl-spin-city-started-final-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP"
cp -a "$SRC" "$BACKUP/src" 2>/dev/null || true
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
  </style>
</head>
<body>
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

let W = 0;
let H = 0;
let DPR = 1;

function resize() {
  DPR = Math.max(1, Math.min(2, devicePixelRatio || 1));
  W = innerWidth;
  H = innerHeight;
  canvas.width = W * DPR;
  canvas.height = H * DPR;
  ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
}
addEventListener("resize", resize);
resize();

function glow(color, blur) {
  ctx.shadowColor = color;
  ctx.shadowBlur = blur;
}

function clearGlow() {
  ctx.shadowBlur = 0;
}

function fadeBackground() {
  ctx.fillStyle = "rgba(5,7,10,0.34)";
  ctx.fillRect(0, 0, W, H);
}

function trajectory(cx, cy, t, time) {
  return {
    x: cx + Math.cos(t) * 382 + Math.sin(t * 2.1 + time * 0.11) * 46,
    y: cy + Math.sin(t) * 142 + Math.cos(t * 1.6 - time * 0.09) * 34
  };
}

function ringPoint(cx, cy, rx, ry, t, phase, wobble) {
  const d =
    Math.sin(t * 5 + phase) * wobble +
    Math.sin(t * 8.5 - phase * 0.7) * wobble * 0.42 +
    Math.cos(t * 3.2 + phase) * wobble * 0.25;

  return {
    x: cx + Math.cos(t) * (rx + d),
    y: cy + Math.sin(t) * (ry + d * 0.55)
  };
}

function rotate(cx, cy, p, r) {
  const dx = p.x - cx;
  const dy = p.y - cy;
  return {
    x: cx + Math.cos(r) * dx - Math.sin(r) * dy,
    y: cy + Math.sin(r) * dx + Math.cos(r) * dy
  };
}

function drawTrajectory(cx, cy, time) {
  glow(C.cyan, 16);
  ctx.strokeStyle = C.cyan;
  ctx.lineWidth = 1.35;
  ctx.globalAlpha = 0.48;

  ctx.beginPath();
  for (let i = 0; i <= 520; i++) {
    const p = trajectory(cx, cy, (i / 520) * Math.PI * 2, time);
    i ? ctx.lineTo(p.x, p.y) : ctx.moveTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  // faint alternate possibility line
  glow(C.purple, 10);
  ctx.strokeStyle = C.purple;
  ctx.lineWidth = 0.8;
  ctx.globalAlpha = 0.18;

  ctx.beginPath();
  for (let i = 0; i <= 520; i++) {
    const p = trajectory(cx, cy, (i / 520) * Math.PI * 2 + 0.22, time + 3.5);
    i ? ctx.lineTo(p.x, p.y) : ctx.moveTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  // slow attention carriers
  for (let i = 0; i < 3; i++) {
    const p = trajectory(cx, cy, time * 0.075 + i * 2.1, time);
    glow(C.green, 20);
    ctx.fillStyle = C.green;
    ctx.globalAlpha = 0.68;
    ctx.beginPath();
    ctx.arc(p.x, p.y, 3.4, 0, Math.PI * 2);
    ctx.fill();
  }

  clearGlow();
  ctx.globalAlpha = 1;
}

function drawRing(cx, cy, rx, ry, rot, color, links, phase, wobble, alpha) {
  ctx.save();
  ctx.translate(cx, cy);
  ctx.rotate(rot);
  ctx.translate(-cx, -cy);

  glow(color, 14);
  ctx.strokeStyle = color;
  ctx.lineWidth = 1.5;
  ctx.globalAlpha = alpha * 0.38;

  ctx.beginPath();
  for (let i = 0; i <= 520; i++) {
    const p = ringPoint(cx, cy, rx, ry, (i / 520) * Math.PI * 2, phase, wobble);
    i ? ctx.lineTo(p.x, p.y) : ctx.moveTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  for (let i = 0; i < links; i++) {
    const t = (i / links) * Math.PI * 2;
    const p = ringPoint(cx, cy, rx, ry, t, phase, wobble);
    const n = ringPoint(cx, cy, rx, ry, t + 0.035, phase, wobble);
    const a = Math.atan2(n.y - p.y, n.x - p.x);

    ctx.save();
    ctx.translate(p.x, p.y);
    ctx.rotate(a);

    glow(color, 10);
    ctx.strokeStyle = color;
    ctx.lineWidth = 1.2;
    ctx.globalAlpha = alpha;
    ctx.strokeRect(-9, -3.5, 18, 7);

    ctx.fillStyle = color;
    ctx.globalAlpha = alpha * 0.16;
    ctx.fillRect(-6, -1.6, 12, 3.2);

    ctx.restore();
  }

  ctx.restore();
  clearGlow();
  ctx.globalAlpha = 1;
}

function pulseNear(x, y, cx, cy, time) {
  let nearest = Infinity;

  for (let i = 0; i < 3; i++) {
    const p = trajectory(cx, cy, time * 0.075 + i * 2.1, time);
    nearest = Math.min(nearest, Math.hypot(p.x - x, p.y - y));
  }

  return Math.max(0, 1 - nearest / 100) ** 4;
}

function drawHook(x, y, a, color, pulse) {
  ctx.save();
  ctx.translate(x, y);
  ctx.rotate(a);

  glow(color, 12 + pulse * 24);
  ctx.strokeStyle = color;
  ctx.lineWidth = 1.6 + pulse;
  ctx.globalAlpha = 0.62 + pulse * 0.28;

  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(16, 0);
  ctx.arc(26, 8, 11, -Math.PI * 0.72, Math.PI * 0.88);
  ctx.stroke();

  ctx.globalAlpha = 0.22 + pulse * 0.3;
  ctx.beginPath();
  ctx.arc(0, 0, 4 + pulse * 8, 0, Math.PI * 2);
  ctx.stroke();

  ctx.restore();
  clearGlow();
  ctx.globalAlpha = 1;
}

function drawHooks(cx, cy, rx, ry, rot, color, time, phase, wobble) {
  const hooks = [0.06, 0.22, 0.46, 0.69, 0.84];

  for (const h of hooks) {
    const t = h * Math.PI * 2;
    const p = ringPoint(cx, cy, rx, ry, t, phase, wobble);
    const n = ringPoint(cx, cy, rx, ry, t + 0.035, phase, wobble);
    const rp = rotate(cx, cy, p, rot);
    const pulse = pulseNear(rp.x, rp.y, cx, cy, time);
    const a = Math.atan2(n.y - p.y, n.x - p.x) + rot + Math.PI * 0.5;

    drawHook(rp.x, rp.y, a, color, pulse);
  }
}

function drawWatchers(cx, cy, time) {
  const anchors = [0.18, 0.53, 0.82];

  for (let i = 0; i < anchors.length; i++) {
    const p = trajectory(cx, cy, anchors[i] * Math.PI * 2, time);
    const d = 90 + Math.sin(time * 0.12 + i) * 16;
    const x = p.x + Math.cos(i * 2.4 + 0.8) * d;
    const y = p.y + Math.sin(i * 2.1 + 1.1) * d;

    glow(C.green, 12);
    ctx.strokeStyle = C.green;
    ctx.lineWidth = 1.35;
    ctx.globalAlpha = 0.42;
    ctx.beginPath();
    ctx.arc(x, y, 5.5, 0, Math.PI * 2);
    ctx.stroke();

    ctx.globalAlpha = 0.14;
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(p.x, p.y);
    ctx.stroke();
  }

  clearGlow();
  ctx.globalAlpha = 1;
}

function drawGhosts(cx, cy, time) {
  for (let i = 0; i < 5; i++) {
    const p = trajectory(cx, cy, time * 0.045 + i * 1.17, time);
    const d = 48 + Math.sin(time * 0.28 + i) * 26;
    const x = p.x + Math.cos(i * 2.7) * d;
    const y = p.y + Math.sin(i * 1.9) * d;

    glow(C.purple, 9);
    ctx.fillStyle = C.purple;
    ctx.globalAlpha = 0.06 + Math.max(0, Math.sin(time * 0.34 + i)) * 0.075;
    ctx.beginPath();
    ctx.arc(x, y, 2.4, 0, Math.PI * 2);
    ctx.fill();
  }

  clearGlow();
  ctx.globalAlpha = 1;
}

function drawCore(cx, cy, time) {
  glow(C.purple, 22);
  ctx.strokeStyle = C.purple;
  ctx.lineWidth = 1.5;
  ctx.globalAlpha = 0.38;

  for (let i = 0; i < 4; i++) {
    ctx.beginPath();
    ctx.arc(cx, cy, 24 + i * 15 + Math.sin(time * 0.65 + i) * 2, 0, Math.PI * 2);
    ctx.stroke();
  }

  glow(C.cyan, 18);
  ctx.fillStyle = C.cyan;
  ctx.globalAlpha = 0.82;
  ctx.beginPath();
  ctx.arc(cx, cy, 4.2, 0, Math.PI * 2);
  ctx.fill();

  clearGlow();
  ctx.globalAlpha = 1;
}

function frame(ms) {
  const time = ms / 1000;
  const cx = W / 2;
  const cy = H / 2 + 10;

  fadeBackground();

  drawTrajectory(cx, cy, time);
  drawGhosts(cx, cy, time);

  const slow = time * 0.072;

  drawRing(cx, cy, 366, 124, slow, C.cyan, 66, time * 0.18, 31, 0.76);
  drawRing(cx, cy, 276, 218, -slow * 0.84, C.purple, 54, -time * 0.16, 25, 0.70);
  drawRing(cx, cy, 438, 78, -slow * 0.46 + 0.54, C.green, 74, time * 0.12, 16, 0.50);

  drawHooks(cx, cy, 366, 124, slow, C.cyan, time, time * 0.18, 31);
  drawHooks(cx, cy, 276, 218, -slow * 0.84, C.purple, time, -time * 0.16, 25);

  drawWatchers(cx, cy, time);
  drawCore(cx, cy, time);

  requestAnimationFrame(frame);
}

ctx.fillStyle = C.bg;
ctx.fillRect(0, 0, W, H);
requestAnimationFrame(frame);
JS

echo "PASS restored started-final wl-spin-city"
echo "Backup: $BACKUP"
echo
echo "Run:"
echo "  cd $APP && npm run tauri dev"
