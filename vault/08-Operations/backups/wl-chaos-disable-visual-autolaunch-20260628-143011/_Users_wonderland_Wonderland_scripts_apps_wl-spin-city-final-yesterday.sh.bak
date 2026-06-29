#!/usr/bin/env bash
set -euo pipefail

APP="${WL_ROOT:-$HOME/Wonderland}/apps/tauri/wl-spin-city"
SRC="$APP/src"
BACKUP="${WL_ROOT:-$HOME/Wonderland}/backups/wl-spin-city-final-yesterday-$(date +%Y%m%d-%H%M%S)"

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
    canvas{display:block;width:100vw;height:100vh;background:#05070A}
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

let W = 0, H = 0, DPR = 1;

function resize() {
  DPR = Math.max(1, Math.min(2, window.devicePixelRatio || 1));
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

function noglow() {
  ctx.shadowBlur = 0;
}

function bg() {
  ctx.fillStyle = C.bg;
  ctx.fillRect(0, 0, W, H);

  const cx = W / 2;
  const cy = H / 2;

  const g = ctx.createRadialGradient(cx, cy, 20, cx, cy, Math.max(W, H) * 0.7);
  g.addColorStop(0, "rgba(112,0,255,0.12)");
  g.addColorStop(0.35, "rgba(0,229,255,0.055)");
  g.addColorStop(1, "rgba(5,7,10,0)");
  ctx.fillStyle = g;
  ctx.fillRect(0, 0, W, H);
}

function trajectory(cx, cy, t, time) {
  return {
    x: cx + Math.cos(t) * 390 + Math.sin(t * 2.3 + time * 0.12) * 42,
    y: cy + Math.sin(t) * 148 + Math.cos(t * 1.6 - time * 0.10) * 30
  };
}

function ringPoint(cx, cy, rx, ry, t, phase, wobble) {
  const chain =
    Math.sin(t * 5 + phase) * wobble +
    Math.sin(t * 9 - phase * 0.6) * wobble * 0.42 +
    Math.cos(t * 3 + phase * 1.2) * wobble * 0.22;

  return {
    x: cx + Math.cos(t) * (rx + chain),
    y: cy + Math.sin(t) * (ry + chain * 0.55)
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
  glow(C.cyan, 18);
  ctx.strokeStyle = C.cyan;
  ctx.lineWidth = 1.4;
  ctx.globalAlpha = 0.42;

  ctx.beginPath();
  for (let i = 0; i <= 520; i++) {
    const p = trajectory(cx, cy, (i / 520) * Math.PI * 2, time);
    i ? ctx.lineTo(p.x, p.y) : ctx.moveTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  ctx.strokeStyle = C.purple;
  ctx.lineWidth = 0.8;
  ctx.globalAlpha = 0.18;

  ctx.beginPath();
  for (let i = 0; i <= 520; i++) {
    const p = trajectory(cx, cy, (i / 520) * Math.PI * 2 + 0.18, time + 4);
    i ? ctx.lineTo(p.x, p.y) : ctx.moveTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  for (let i = 0; i < 3; i++) {
    const p = trajectory(cx, cy, time * 0.09 + i * 2.1, time);
    glow(C.green, 20);
    ctx.fillStyle = C.green;
    ctx.globalAlpha = 0.68;
    ctx.beginPath();
    ctx.arc(p.x, p.y, 3.1, 0, Math.PI * 2);
    ctx.fill();
  }

  noglow();
  ctx.globalAlpha = 1;
}

function drawRing(cx, cy, rx, ry, rot, color, links, phase, wobble, alpha) {
  ctx.save();
  ctx.translate(cx, cy);
  ctx.rotate(rot);
  ctx.translate(-cx, -cy);

  glow(color, 14);
  ctx.strokeStyle = color;
  ctx.lineWidth = 1.6;
  ctx.globalAlpha = alpha * 0.42;

  ctx.beginPath();
  for (let i = 0; i <= 520; i++) {
    const p = ringPoint(cx, cy, rx, ry, (i / 520) * Math.PI * 2, phase, wobble);
    i ? ctx.lineTo(p.x, p.y) : ctx.moveTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  for (let i = 0; i < links; i++) {
    const a = (i / links) * Math.PI * 2;
    const p = ringPoint(cx, cy, rx, ry, a, phase, wobble);
    const n = ringPoint(cx, cy, rx, ry, a + 0.035, phase, wobble);
    const ang = Math.atan2(n.y - p.y, n.x - p.x);

    ctx.save();
    ctx.translate(p.x, p.y);
    ctx.rotate(ang);

    ctx.strokeStyle = color;
    ctx.lineWidth = 1.25;
    ctx.globalAlpha = alpha;
    glow(color, 10);
    ctx.strokeRect(-9, -3.6, 18, 7.2);

    ctx.fillStyle = color;
    ctx.globalAlpha = alpha * 0.18;
    ctx.fillRect(-6, -1.7, 12, 3.4);

    ctx.restore();
  }

  ctx.restore();
  noglow();
  ctx.globalAlpha = 1;
}

function hookShape(x, y, a, color, pulse) {
  ctx.save();
  ctx.translate(x, y);
  ctx.rotate(a);

  glow(color, 14 + pulse * 20);
  ctx.strokeStyle = color;
  ctx.lineWidth = 1.7 + pulse;
  ctx.globalAlpha = 0.62 + pulse * 0.28;

  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(16, 0);
  ctx.arc(26, 8, 11, -Math.PI * 0.74, Math.PI * 0.88);
  ctx.stroke();

  ctx.globalAlpha = 0.22 + pulse * 0.3;
  ctx.beginPath();
  ctx.arc(0, 0, 4 + pulse * 8, 0, Math.PI * 2);
  ctx.stroke();

  ctx.restore();
  noglow();
  ctx.globalAlpha = 1;
}

function pulseNearTrajectory(x, y, cx, cy, time) {
  let near = Infinity;
  for (let i = 0; i < 3; i++) {
    const p = trajectory(cx, cy, time * 0.09 + i * 2.1, time);
    near = Math.min(near, Math.hypot(p.x - x, p.y - y));
  }
  return Math.max(0, 1 - near / 105) ** 4;
}

function drawHooks(cx, cy, rx, ry, rot, color, time, wobble, phase) {
  const points = [0.06, 0.23, 0.47, 0.71, 0.86];

  for (const h of points) {
    const a = h * Math.PI * 2;
    const p = ringPoint(cx, cy, rx, ry, a, phase, wobble);
    const n = ringPoint(cx, cy, rx, ry, a + 0.035, phase, wobble);
    const rp = rotate(cx, cy, p, rot);
    const pulse = pulseNearTrajectory(rp.x, rp.y, cx, cy, time);
    const angle = Math.atan2(n.y - p.y, n.x - p.x) + rot + Math.PI * 0.52;

    hookShape(rp.x, rp.y, angle, color, pulse);

    if (pulse > 0.05) {
      glow(color, 26 * pulse);
      ctx.strokeStyle = color;
      ctx.globalAlpha = 0.22 + pulse * 0.35;
      ctx.lineWidth = 1 + pulse * 1.4;
      ctx.beginPath();
      ctx.arc(rp.x, rp.y, 18 + pulse * 32, 0, Math.PI * 2);
      ctx.stroke();
      noglow();
      ctx.globalAlpha = 1;
    }
  }
}

function drawWatchers(cx, cy, time) {
  const anchors = [0.18, 0.52, 0.82];

  for (let i = 0; i < anchors.length; i++) {
    const a = anchors[i];
    const p = trajectory(cx, cy, a * Math.PI * 2 + Math.sin(time * 0.05) * 0.14, time);
    const d = 84 + Math.sin(time * 0.14 + i) * 12;
    const x = p.x + Math.cos(i * 2.4 + 0.7) * d;
    const y = p.y + Math.sin(i * 2.1 + 1.2) * d;

    glow(C.green, 12);
    ctx.strokeStyle = C.green;
    ctx.lineWidth = 1.4;
    ctx.globalAlpha = 0.46;
    ctx.beginPath();
    ctx.arc(x, y, 5.5, 0, Math.PI * 2);
    ctx.stroke();

    ctx.globalAlpha = 0.16;
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(p.x, p.y);
    ctx.stroke();
  }

  noglow();
  ctx.globalAlpha = 1;
}

function drawGhosts(cx, cy, time) {
  for (let i = 0; i < 5; i++) {
    const p = trajectory(cx, cy, time * 0.055 + i * 1.13, time);
    const d = 45 + Math.sin(time * 0.33 + i) * 24;
    const x = p.x + Math.cos(i * 2.7) * d;
    const y = p.y + Math.sin(i * 1.9) * d;

    glow(C.purple, 10);
    ctx.fillStyle = C.purple;
    ctx.globalAlpha = 0.07 + Math.max(0, Math.sin(time * 0.4 + i)) * 0.08;
    ctx.beginPath();
    ctx.arc(x, y, 2.4, 0, Math.PI * 2);
    ctx.fill();

    ctx.globalAlpha *= 0.45;
    ctx.strokeStyle = C.purple;
    ctx.beginPath();
    ctx.moveTo(p.x, p.y);
    ctx.lineTo(x, y);
    ctx.stroke();
  }

  noglow();
  ctx.globalAlpha = 1;
}

function drawCore(cx, cy, time) {
  glow(C.purple, 24);
  ctx.strokeStyle = C.purple;
  ctx.lineWidth = 1.6;
  ctx.globalAlpha = 0.42;

  for (let i = 0; i < 4; i++) {
    ctx.beginPath();
    ctx.arc(cx, cy, 24 + i * 15 + Math.sin(time * 0.7 + i) * 2, 0, Math.PI * 2);
    ctx.stroke();
  }

  glow(C.cyan, 18);
  ctx.fillStyle = C.cyan;
  ctx.globalAlpha = 0.82;
  ctx.beginPath();
  ctx.arc(cx, cy, 4.2, 0, Math.PI * 2);
  ctx.fill();

  noglow();
  ctx.globalAlpha = 1;
}

function frame(ms) {
  const time = ms / 1000;
  const cx = W / 2;
  const cy = H / 2 + 10;

  bg();
  drawTrajectory(cx, cy, time);
  drawGhosts(cx, cy, time);

  const slow = time * 0.078;

  drawRing(cx, cy, 368, 124, slow, C.cyan, 66, time * 0.22, 30, 0.78);
  drawRing(cx, cy, 276, 218, -slow * 0.82, C.purple, 54, -time * 0.19, 24, 0.72);
  drawRing(cx, cy, 438, 78, -slow * 0.47 + 0.54, C.green, 74, time * 0.16, 16, 0.54);

  drawHooks(cx, cy, 368, 124, slow, C.cyan, time, 30, time * 0.22);
  drawHooks(cx, cy, 276, 218, -slow * 0.82, C.purple, time, 24, -time * 0.19);

  drawWatchers(cx, cy, time);
  drawCore(cx, cy, time);

  requestAnimationFrame(frame);
}

requestAnimationFrame(frame);
JS

echo "PASS installed final-yesterday wl-spin-city"
echo "Backup: $BACKUP"
echo
echo "Run:"
echo "  cd $APP && npm run tauri dev"
