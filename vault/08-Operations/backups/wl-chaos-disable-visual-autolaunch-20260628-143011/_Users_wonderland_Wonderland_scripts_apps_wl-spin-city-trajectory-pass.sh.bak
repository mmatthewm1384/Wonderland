#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APP="$ROOT/apps/tauri/wl-spin-city"
SRC="$APP/src/main.js"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$ROOT/backups/wl-spin-city-trajectory-pass-$STAMP"

[[ -f "$SRC" ]] || { echo "FAIL: missing $SRC"; exit 1; }

mkdir -p "$BACKUP"
cp -a "$APP/src" "$BACKUP/src"

cat > "$SRC" <<'JS'
const canvas = document.getElementById("scene");
const ctx = canvas.getContext("2d");

const COLORS = {
  bg: "#05070A",
  cyan: "#00E5FF",
  purple: "#7000FF",
  green: "#00FF66"
};

let W = 0;
let H = 0;
let DPR = 1;

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

function glow(color, blur = 16) {
  ctx.shadowColor = color;
  ctx.shadowBlur = blur;
}

function noGlow() {
  ctx.shadowBlur = 0;
}

function trajectoryPoint(cx, cy, t, time) {
  const x =
    cx +
    Math.cos(t) * 380 +
    Math.sin(t * 2.2 + time * 0.22) * 42;

  const y =
    cy +
    Math.sin(t) * 145 +
    Math.cos(t * 1.7 - time * 0.18) * 34;

  return { x, y };
}

function drawTrajectory(cx, cy, time) {
  glow(COLORS.cyan, 20);

  ctx.lineWidth = 2;
  ctx.strokeStyle = COLORS.cyan;
  ctx.globalAlpha = 0.72;

  ctx.beginPath();
  for (let i = 0; i <= 420; i++) {
    const t = (i / 420) * Math.PI * 2;
    const p = trajectoryPoint(cx, cy, t, time);
    if (i === 0) ctx.moveTo(p.x, p.y);
    else ctx.lineTo(p.x, p.y);
  }
  ctx.stroke();

  // Secondary predicted path
  ctx.strokeStyle = COLORS.purple;
  ctx.lineWidth = 1;
  ctx.globalAlpha = 0.32;

  ctx.beginPath();
  for (let i = 0; i <= 420; i++) {
    const t = (i / 420) * Math.PI * 2;
    const p = trajectoryPoint(cx, cy, t + 0.18, time + 3.4);
    if (i === 0) ctx.moveTo(p.x, p.y);
    else ctx.lineTo(p.x, p.y);
  }
  ctx.stroke();

  // Moving attention carrier
  for (let i = 0; i < 4; i++) {
    const t = time * 0.13 + i * 1.57;
    const p = trajectoryPoint(cx, cy, t, time);

    glow(COLORS.green, 24);
    ctx.fillStyle = COLORS.green;
    ctx.globalAlpha = 0.88;
    ctx.beginPath();
    ctx.arc(p.x, p.y, 4.5, 0, Math.PI * 2);
    ctx.fill();

    ctx.globalAlpha = 0.2;
    ctx.beginPath();
    ctx.arc(p.x, p.y, 16, 0, Math.PI * 2);
    ctx.strokeStyle = COLORS.green;
    ctx.stroke();
  }

  noGlow();
  ctx.globalAlpha = 1;
}

function pointOnRing(cx, cy, rx, ry, t, wobble, phase) {
  const distortion =
    Math.sin(t * 5 + phase) * wobble +
    Math.sin(t * 9 - phase) * wobble * 0.35;

  return {
    x: cx + Math.cos(t) * (rx + distortion),
    y: cy + Math.sin(t) * (ry + distortion * 0.5)
  };
}

function drawChainRing(cx, cy, rx, ry, rotation, color, links, wobble, phase) {
  ctx.save();
  ctx.translate(cx, cy);
  ctx.rotate(rotation);
  ctx.translate(-cx, -cy);

  glow(color, 12);
  ctx.strokeStyle = color;
  ctx.globalAlpha = 0.22;
  ctx.lineWidth = 2;

  ctx.beginPath();
  for (let i = 0; i <= 360; i++) {
    const t = (i / 360) * Math.PI * 2;
    const p = pointOnRing(cx, cy, rx, ry, t, wobble, phase);
    if (i === 0) ctx.moveTo(p.x, p.y);
    else ctx.lineTo(p.x, p.y);
  }
  ctx.closePath();
  ctx.stroke();

  for (let i = 0; i < links; i++) {
    const t = (i / links) * Math.PI * 2;
    const p = pointOnRing(cx, cy, rx, ry, t, wobble, phase);
    const p2 = pointOnRing(cx, cy, rx, ry, t + 0.035, wobble, phase);
    const angle = Math.atan2(p2.y - p.y, p2.x - p.x);

    ctx.save();
    ctx.translate(p.x, p.y);
    ctx.rotate(angle);

    ctx.globalAlpha = 0.78;
    ctx.strokeStyle = color;
    ctx.lineWidth = 1.5;
    ctx.strokeRect(-10, -4, 20, 8);

    ctx.globalAlpha = 0.26;
    ctx.fillStyle = color;
    ctx.fillRect(-7, -2, 14, 4);

    ctx.restore();
  }

  ctx.restore();
  noGlow();
  ctx.globalAlpha = 1;
}

function drawHook(x, y, angle, color) {
  ctx.save();
  ctx.translate(x, y);
  ctx.rotate(angle);

  glow(color, 14);
  ctx.strokeStyle = color;
  ctx.lineWidth = 2;
  ctx.globalAlpha = 0.82;

  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(14, 0);
  ctx.arc(23, 8, 10, -Math.PI * 0.72, Math.PI * 0.9);
  ctx.stroke();

  ctx.restore();
  noGlow();
  ctx.globalAlpha = 1;
}

function drawHooks(cx, cy, rx, ry, rotation, color, time) {
  const positions = [0.09, 0.24, 0.43, 0.61, 0.79];

  for (const h of positions) {
    const t = h * Math.PI * 2;
    const local = pointOnRing(cx, cy, rx, ry, t, 18, time * 0.3);
    const next = pointOnRing(cx, cy, rx, ry, t + 0.04, 18, time * 0.3);

    const dx = local.x - cx;
    const dy = local.y - cy;

    const x = cx + Math.cos(rotation) * dx - Math.sin(rotation) * dy;
    const y = cy + Math.sin(rotation) * dx + Math.cos(rotation) * dy;

    const angle = Math.atan2(next.y - local.y, next.x - local.x) + rotation + Math.PI * 0.5;
    drawHook(x, y, angle, color);
  }
}

function drawWatchers(cx, cy, time) {
  const positions = [0.14, 0.36, 0.58, 0.83];

  for (const pos of positions) {
    const p = trajectoryPoint(cx, cy, pos * Math.PI * 2, time);
    const offset = 58 + Math.sin(time * 0.3 + pos * 20) * 12;
    const x = p.x + Math.cos(pos * 12) * offset;
    const y = p.y + Math.sin(pos * 12) * offset;

    glow(COLORS.green, 12);
    ctx.strokeStyle = COLORS.green;
    ctx.globalAlpha = 0.62;
    ctx.lineWidth = 1.5;

    ctx.beginPath();
    ctx.arc(x, y, 7, 0, Math.PI * 2);
    ctx.stroke();

    ctx.globalAlpha = 0.22;
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(p.x, p.y);
    ctx.stroke();
  }

  noGlow();
  ctx.globalAlpha = 1;
}

function drawGhosts(cx, cy, time) {
  for (let i = 0; i < 9; i++) {
    const t = time * 0.09 + i * 0.7;
    const p = trajectoryPoint(cx, cy, t, time);
    const edge = 28 + Math.sin(time + i) * 22;

    glow(COLORS.purple, 10);
    ctx.fillStyle = COLORS.purple;
    ctx.globalAlpha = 0.12 + Math.sin(time * 0.7 + i) * 0.05;

    ctx.beginPath();
    ctx.arc(
      p.x + Math.cos(i * 2.4) * edge,
      p.y + Math.sin(i * 1.9) * edge,
      2.5,
      0,
      Math.PI * 2
    );
    ctx.fill();
  }

  noGlow();
  ctx.globalAlpha = 1;
}

function drawCore(cx, cy, time) {
  glow(COLORS.purple, 22);

  ctx.strokeStyle = COLORS.purple;
  ctx.lineWidth = 2;
  ctx.globalAlpha = 0.74;

  for (let i = 0; i < 4; i++) {
    ctx.beginPath();
    ctx.arc(cx, cy, 24 + i * 14 + Math.sin(time + i) * 2, 0, Math.PI * 2);
    ctx.stroke();
  }

  glow(COLORS.cyan, 20);
  ctx.fillStyle = COLORS.cyan;
  ctx.globalAlpha = 0.95;
  ctx.beginPath();
  ctx.arc(cx, cy, 5, 0, Math.PI * 2);
  ctx.fill();

  noGlow();
  ctx.globalAlpha = 1;
}

function frame() {
  const time = performance.now() / 1000;
  const cx = W / 2;
  const cy = H / 2 + 20;

  ctx.fillStyle = COLORS.bg;
  ctx.fillRect(0, 0, W, H);

  drawTrajectory(cx, cy, time);
  drawGhosts(cx, cy, time);

  const slow = time * 0.16;

  drawChainRing(cx, cy, 330, 112, slow, COLORS.cyan, 58, 22, time * 0.42);
  drawChainRing(cx, cy, 252, 194, -slow * 0.86, COLORS.purple, 48, 18, -time * 0.36);
  drawChainRing(cx, cy, 415, 64, -slow * 0.5 + 0.55, COLORS.green, 70, 12, time * 0.25);

  drawHooks(cx, cy, 330, 112, slow, COLORS.cyan, time);
  drawHooks(cx, cy, 252, 194, -slow * 0.86, COLORS.purple, time);

  drawWatchers(cx, cy, time);
  drawCore(cx, cy, time);

  requestAnimationFrame(frame);
}

frame();
JS

echo "PASS: trajectory authority pass installed"
echo "Backup: $BACKUP"
echo
echo "Run:"
echo "  cd $APP"
echo "  npm run tauri dev"
