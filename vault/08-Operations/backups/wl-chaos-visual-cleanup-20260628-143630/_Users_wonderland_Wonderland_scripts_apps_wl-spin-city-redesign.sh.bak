#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APP="$ROOT/apps/tauri/wl-spin-city"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$ROOT/backups/wl-spin-city-redesign-$STAMP"

mkdir -p "$BACKUP"

if [[ ! -d "$APP" ]]; then
  echo "FAIL: missing $APP"
  exit 1
fi

cp -a "$APP/src" "$BACKUP/src"

mkdir -p "$APP/src"

cat > "$APP/src/index.html" <<'HTML'
<!doctype html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>wl-spin-city</title>
  <style>
    html, body {
      margin: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: #05070A;
      font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    }

    canvas {
      display: block;
      width: 100vw;
      height: 100vh;
    }

    #hud {
      position: fixed;
      left: 22px;
      top: 18px;
      color: #00E5FF;
      font-size: 12px;
      letter-spacing: 0.12em;
      text-shadow: 0 0 12px #00E5FF;
      user-select: none;
      pointer-events: none;
    }

    #hud small {
      display: block;
      margin-top: 8px;
      color: #00FF66;
      opacity: 0.75;
      letter-spacing: 0.08em;
    }
  </style>
</head>
<body>
  <div id="hud">
    WL-SPIN-CITY
    <small>counter-rotating orbital chain geometry</small>
  </div>
  <canvas id="scene"></canvas>
  <script type="module" src="./main.js"></script>
</body>
</html>
HTML

cat > "$APP/src/main.js" <<'JS'
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
  canvas.style.width = `${W}px`;
  canvas.style.height = `${H}px`;
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

function pointOnChainRing(cx, cy, rx, ry, t, wobble, phase) {
  const wave =
    Math.sin(t * 5 + phase) * wobble +
    Math.sin(t * 9 - phase * 0.7) * wobble * 0.38 +
    Math.cos(t * 3 + phase * 1.3) * wobble * 0.26;

  const rxf = rx + wave;
  const ryf = ry + wave * 0.55;

  return {
    x: cx + Math.cos(t) * rxf,
    y: cy + Math.sin(t) * ryf
  };
}

function drawChainRing({
  cx,
  cy,
  rx,
  ry,
  rotation,
  wobble,
  phase,
  links,
  color,
  direction,
  width
}) {
  ctx.save();
  ctx.translate(cx, cy);
  ctx.rotate(rotation);
  ctx.translate(-cx, -cy);

  // ghost full path
  ctx.beginPath();
  for (let i = 0; i <= 360; i++) {
    const t = (i / 360) * Math.PI * 2;
    const p = pointOnChainRing(cx, cy, rx, ry, t, wobble, phase);
    if (i === 0) ctx.moveTo(p.x, p.y);
    else ctx.lineTo(p.x, p.y);
  }
  glow(color, 10);
  ctx.strokeStyle = color;
  ctx.globalAlpha = 0.20;
  ctx.lineWidth = width;
  ctx.stroke();

  // segmented chain blocks
  for (let i = 0; i < links; i++) {
    const t = (i / links) * Math.PI * 2;
    const p = pointOnChainRing(cx, cy, rx, ry, t, wobble, phase);
    const p2 = pointOnChainRing(cx, cy, rx, ry, t + 0.035 * direction, wobble, phase);
    const a = Math.atan2(p2.y - p.y, p2.x - p.x);

    ctx.save();
    ctx.translate(p.x, p.y);
    ctx.rotate(a);
    glow(color, 14);

    ctx.globalAlpha = 0.86;
    ctx.strokeStyle = color;
    ctx.lineWidth = 1.6;
    ctx.strokeRect(-10, -4, 20, 8);

    ctx.globalAlpha = 0.32;
    ctx.fillStyle = color;
    ctx.fillRect(-7, -2, 14, 4);

    ctx.restore();
  }

  ctx.restore();
  noGlow();
  ctx.globalAlpha = 1;
}

function drawHook(x, y, angle, color, size = 34) {
  ctx.save();
  ctx.translate(x, y);
  ctx.rotate(angle);

  glow(color, 16);
  ctx.strokeStyle = color;
  ctx.lineWidth = 2;
  ctx.globalAlpha = 0.88;

  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(size * 0.38, 0);
  ctx.arc(size * 0.55, size * 0.18, size * 0.22, -Math.PI * 0.72, Math.PI * 0.88);
  ctx.stroke();

  ctx.globalAlpha = 0.35;
  ctx.beginPath();
  ctx.arc(size * 0.04, 0, 4, 0, Math.PI * 2);
  ctx.stroke();

  ctx.restore();
  noGlow();
  ctx.globalAlpha = 1;
}

function drawAttachedHooks(cx, cy, rx, ry, rotation, wobble, phase, color, offset = 0) {
  const hookPositions = [0.08, 0.21, 0.39, 0.57, 0.72, 0.88];

  for (const h of hookPositions) {
    const t = (h + offset) * Math.PI * 2;
    const p = pointOnChainRing(cx, cy, rx, ry, t, wobble, phase);
    const p2 = pointOnChainRing(cx, cy, rx, ry, t + 0.03, wobble, phase);
    const tangent = Math.atan2(p2.y - p.y, p2.x - p.x);

    const x =
      cx +
      Math.cos(rotation) * (p.x - cx) -
      Math.sin(rotation) * (p.y - cy);

    const y =
      cy +
      Math.sin(rotation) * (p.x - cx) +
      Math.cos(rotation) * (p.y - cy);

    drawHook(x, y, tangent + rotation + Math.PI * 0.5, color);
  }
}

function drawTrajectory(cx, cy, time) {
  const routes = [
    { rx: 430, ry: 130, color: COLORS.cyan, speed: 0.08, alpha: 0.45 },
    { rx: 360, ry: 215, color: COLORS.purple, speed: -0.055, alpha: 0.34 },
    { rx: 510, ry: 82, color: COLORS.green, speed: 0.045, alpha: 0.30 }
  ];

  for (const r of routes) {
    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(Math.sin(time * 0.08) * 0.25);
    ctx.translate(-cx, -cy);

    glow(r.color, 12);
    ctx.strokeStyle = r.color;
    ctx.lineWidth = 1;
    ctx.globalAlpha = r.alpha;

    ctx.beginPath();
    for (let i = 0; i <= 260; i++) {
      const t = (i / 260) * Math.PI * 2;
      const x = cx + Math.cos(t) * r.rx;
      const y = cy + Math.sin(t) * r.ry + Math.sin(t * 3 + time) * 8;
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }
    ctx.stroke();

    for (let i = 0; i < 3; i++) {
      const t = time * r.speed + i * 2.1;
      const x = cx + Math.cos(t) * r.rx;
      const y = cy + Math.sin(t) * r.ry + Math.sin(t * 3 + time) * 8;

      ctx.globalAlpha = 0.85;
      ctx.fillStyle = r.color;
      ctx.beginPath();
      ctx.arc(x, y, 3.2, 0, Math.PI * 2);
      ctx.fill();
    }

    ctx.restore();
  }

  noGlow();
  ctx.globalAlpha = 1;
}

function drawWatchers(cx, cy, time) {
  const watchers = [
    [-330, -160, 0.9],
    [330, -190, 0.7],
    [-420, 120, 0.55],
    [410, 155, 0.6],
    [80, -280, 0.75],
    [-110, 245, 0.5]
  ];

  for (const [dx, dy, s] of watchers) {
    const drift = Math.sin(time * 0.45 + dx) * 7;
    const x = cx + dx + drift;
    const y = cy + dy + Math.cos(time * 0.38 + dy) * 5;

    glow(COLORS.green, 14);
    ctx.strokeStyle = COLORS.green;
    ctx.fillStyle = COLORS.bg;
    ctx.globalAlpha = 0.72;

    ctx.beginPath();
    ctx.arc(x, y, 6 * s, 0, Math.PI * 2);
    ctx.stroke();

    ctx.globalAlpha = 0.35;
    ctx.beginPath();
    ctx.moveTo(x - 18 * s, y);
    ctx.lineTo(x - 7 * s, y);
    ctx.moveTo(x + 7 * s, y);
    ctx.lineTo(x + 18 * s, y);
    ctx.moveTo(x, y - 18 * s);
    ctx.lineTo(x, y - 7 * s);
    ctx.moveTo(x, y + 7 * s);
    ctx.lineTo(x, y + 18 * s);
    ctx.stroke();
  }

  noGlow();
  ctx.globalAlpha = 1;
}

function drawCore(cx, cy, time) {
  glow(COLORS.purple, 20);

  ctx.globalAlpha = 0.75;
  ctx.strokeStyle = COLORS.purple;
  ctx.lineWidth = 2;

  for (let i = 0; i < 5; i++) {
    ctx.beginPath();
    ctx.arc(cx, cy, 22 + i * 14 + Math.sin(time + i) * 2, 0, Math.PI * 2);
    ctx.stroke();
  }

  glow(COLORS.cyan, 22);
  ctx.fillStyle = COLORS.cyan;
  ctx.globalAlpha = 0.92;
  ctx.beginPath();
  ctx.arc(cx, cy, 5, 0, Math.PI * 2);
  ctx.fill();

  noGlow();
  ctx.globalAlpha = 1;
}

function draw() {
  const time = performance.now() / 1000;
  const cx = W / 2;
  const cy = H / 2 + 20;

  ctx.clearRect(0, 0, W, H);
  ctx.fillStyle = COLORS.bg;
  ctx.fillRect(0, 0, W, H);

  drawTrajectory(cx, cy, time);
  drawWatchers(cx, cy, time);

  const slow = time * 0.18;

  drawChainRing({
    cx,
    cy,
    rx: 330,
    ry: 112,
    rotation: slow,
    wobble: 22,
    phase: time * 0.55,
    links: 58,
    color: COLORS.cyan,
    direction: 1,
    width: 2
  });

  drawChainRing({
    cx,
    cy,
    rx: 255,
    ry: 196,
    rotation: -slow * 0.82,
    wobble: 18,
    phase: time * -0.42,
    links: 48,
    color: COLORS.purple,
    direction: -1,
    width: 2
  });

  drawChainRing({
    cx,
    cy,
    rx: 410,
    ry: 64,
    rotation: -slow * 0.46 + 0.55,
    wobble: 12,
    phase: time * 0.32,
    links: 70,
    color: COLORS.green,
    direction: -1,
    width: 1.5
  });

  drawAttachedHooks(cx, cy, 330, 112, slow, 22, time * 0.55, COLORS.cyan, 0.0);
  drawAttachedHooks(cx, cy, 255, 196, -slow * 0.82, 18, time * -0.42, COLORS.purple, 0.04);

  drawCore(cx, cy, time);

  requestAnimationFrame(draw);
}

draw();
JS

echo "PASS: wl-spin-city redesign installed"
echo "Backup: $BACKUP"
echo
echo "Next:"
echo "  cd $APP"
echo "  npm run tauri dev"
