#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
APP="$WL_HOME/apps/tauri/wl-spin-city"
SRC="$APP/src/main.js"
ALT_SRC="$APP/src/App.jsx"
BACKUP="$APP/.backup-cone-time-design-$(date +%Y%m%d-%H%M%S)"

echo "== apply spin-the-city cone-time design =="
echo "APP=$APP"
echo "BACKUP=$BACKUP"

test -d "$APP" || { echo "FAIL missing app: $APP"; exit 1; }

if [[ -f "$SRC" ]]; then
  TARGET="$SRC"
elif [[ -f "$ALT_SRC" ]]; then
  TARGET="$ALT_SRC"
else
  TARGET="$(find "$APP/src" -maxdepth 2 -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' \) | head -1)"
fi

test -n "${TARGET:-}" || { echo "FAIL no frontend source found"; exit 1; }
test -f "$TARGET" || { echo "FAIL target missing: $TARGET"; exit 1; }

mkdir -p "$BACKUP"
cp -a "$TARGET" "$BACKUP/$(basename "$TARGET")"

cat > "$TARGET" <<'EOF'
const canvas = document.createElement("canvas");
document.body.innerHTML = "";
document.body.appendChild(canvas);

document.documentElement.style.margin = "0";
document.documentElement.style.padding = "0";
document.body.style.margin = "0";
document.body.style.padding = "0";
document.body.style.overflow = "hidden";
document.body.style.background = "#05070A";

const ctx = canvas.getContext("2d");

const WL = {
  bg: "#05070A",
  cyan: "#00E5FF",
  purple: "#7000FF",
  green: "#00FF66",
  amber: "#FFB000",
  white: "#EAF7FF",
  gray: "#5E6773"
};

let W = 0;
let H = 0;
let DPR = Math.max(1, window.devicePixelRatio || 1);

const gaze = {
  x: 0.5,
  y: 0.5,
  px: 0.5,
  py: 0.5,
  vx: 0,
  vy: 0,
  speed: 0,
  dwell: 0,
  lastMove: performance.now()
};

const state = {
  time: 0,
  spin: 0,
  temporalDepth: 0,
  pressure: 0,
  route: []
};

function resize() {
  W = window.innerWidth;
  H = window.innerHeight;
  DPR = Math.max(1, window.devicePixelRatio || 1);
  canvas.width = Math.floor(W * DPR);
  canvas.height = Math.floor(H * DPR);
  canvas.style.width = `${W}px`;
  canvas.style.height = `${H}px`;
  ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
}

window.addEventListener("resize", resize);
resize();

function clamp(v, a, b) {
  return Math.max(a, Math.min(b, v));
}

function lerp(a, b, t) {
  return a + (b - a) * t;
}

function smoothstep(edge0, edge1, x) {
  const t = clamp((x - edge0) / (edge1 - edge0), 0, 1);
  return t * t * (3 - 2 * t);
}

function onPointer(e) {
  const nx = clamp(e.clientX / Math.max(1, W), 0, 1);
  const ny = clamp(e.clientY / Math.max(1, H), 0, 1);
  gaze.vx = nx - gaze.x;
  gaze.vy = ny - gaze.y;
  gaze.speed = Math.hypot(gaze.vx, gaze.vy);
  gaze.px = gaze.x;
  gaze.py = gaze.y;
  gaze.x = nx;
  gaze.y = ny;
  gaze.lastMove = performance.now();

  state.route.push({ x: nx, y: ny, t: performance.now() });
  if (state.route.length > 180) state.route.shift();
}

window.addEventListener("pointermove", onPointer, { passive: true });

function coneRadius(layer, maxRadius) {
  // Cone-time math:
  // tip = 1 minute
  // vertical sections = 60
  // outer symbolic radius = 168 hours/week
  // visual radius normalizes symbolic cone radius into screen space.
  const n = layer / 60;
  const symbolicRadius = 168 * Math.pow(n, 1.35);
  return (symbolicRadius / 168) * maxRadius;
}

function coneTime(layer) {
  // Tip minute expands into outer day-ring.
  // 1440 minute expansion across 60 sections.
  return Math.pow(1440, layer / 60);
}

function drawBackground(cx, cy, maxR) {
  const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, maxR * 1.4);
  g.addColorStop(0, "rgba(0,229,255,0.10)");
  g.addColorStop(0.28, "rgba(112,0,255,0.08)");
  g.addColorStop(0.66, "rgba(0,255,102,0.035)");
  g.addColorStop(1, "rgba(5,7,10,1)");
  ctx.fillStyle = g;
  ctx.fillRect(0, 0, W, H);
}

function drawConeSkeleton(cx, cy, maxR, t) {
  ctx.save();
  ctx.globalCompositeOperation = "lighter";

  // Cone side rays
  const rays = 24;
  for (let i = 0; i < rays; i++) {
    const a = (i / rays) * Math.PI * 2 + t * 0.04;
    const x = cx + Math.cos(a) * maxR;
    const y = cy + Math.sin(a) * maxR * 0.58;
    ctx.strokeStyle = i % 2 === 0 ? "rgba(0,229,255,0.16)" : "rgba(112,0,255,0.12)";
    ctx.lineWidth = 0.75;
    ctx.beginPath();
    ctx.moveTo(cx, cy);
    ctx.lineTo(x, y);
    ctx.stroke();
  }

  ctx.restore();
}

function drawRing(cx, cy, r, layer, t, gazeAngle, gazeRNorm) {
  const dir = layer % 2 === 0 ? 1 : -1;
  const timeScale = coneTime(layer);
  const speed = dir * (0.08 + 0.7 / Math.sqrt(layer + 1));
  const phase = t * speed + layer * 0.37;
  const depth = layer / 60;

  const gazeInfluence = smoothstep(0.18, 0.0, Math.abs(gazeRNorm - depth));
  const deform = 1 + gazeInfluence * 0.13 + Math.sin(t * 1.4 + layer) * 0.018;

  ctx.save();
  ctx.globalCompositeOperation = "lighter";
  ctx.translate(cx, cy);
  ctx.rotate(phase);

  const segments = Math.max(24, Math.floor(12 + depth * 84));
  const yScale = 0.58 + depth * 0.22;

  ctx.beginPath();
  for (let i = 0; i <= segments; i++) {
    const p = i / segments;
    const a = p * Math.PI * 2;
    const wave =
      1 +
      Math.sin(a * 3 + phase * 2) * 0.018 +
      Math.sin(a * 7 - phase) * 0.012 +
      gazeInfluence * Math.cos(a - gazeAngle - phase) * 0.085;

    const rr = r * deform * wave;
    const x = Math.cos(a) * rr;
    const y = Math.sin(a) * rr * yScale;

    if (i === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  }

  const alpha = 0.10 + depth * 0.23 + gazeInfluence * 0.35;
  ctx.strokeStyle =
    layer % 3 === 0
      ? `rgba(0,229,255,${alpha})`
      : layer % 3 === 1
      ? `rgba(112,0,255,${alpha})`
      : `rgba(0,255,102,${alpha})`;

  ctx.lineWidth = 0.8 + depth * 1.2 + gazeInfluence * 1.5;
  ctx.stroke();

  // moving gate markers: these are the route opportunities created by counter-rotation
  const gates = Math.max(2, Math.floor(3 + depth * 9));
  for (let g = 0; g < gates; g++) {
    const a = (g / gates) * Math.PI * 2 + phase * 0.7;
    const gx = Math.cos(a) * r;
    const gy = Math.sin(a) * r * yScale;
    const pulse = 0.5 + 0.5 * Math.sin(t * 3 + g + layer);
    ctx.fillStyle = `rgba(234,247,255,${0.06 + pulse * 0.16 + gazeInfluence * 0.2})`;
    ctx.beginPath();
    ctx.arc(gx, gy, 1.2 + depth * 2.4 + gazeInfluence * 2.0, 0, Math.PI * 2);
    ctx.fill();
  }

  ctx.restore();

  return { timeScale, gazeInfluence };
}

function drawRoute(cx, cy, maxR) {
  if (state.route.length < 2) return;

  ctx.save();
  ctx.globalCompositeOperation = "lighter";
  ctx.lineWidth = 1.5;
  ctx.beginPath();

  for (let i = 0; i < state.route.length; i++) {
    const p = state.route[i];
    const x = p.x * W;
    const y = p.y * H;
    if (i === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  }

  ctx.strokeStyle = "rgba(0,229,255,0.28)";
  ctx.stroke();

  const head = state.route[state.route.length - 1];
  ctx.fillStyle = "rgba(0,255,102,0.65)";
  ctx.beginPath();
  ctx.arc(head.x * W, head.y * H, 4.5, 0, Math.PI * 2);
  ctx.fill();

  ctx.restore();
}

function drawCityManifestation(cx, cy, maxR, t) {
  // The city is an output of the temporal state, not a background.
  const baseY = cy + maxR * 0.52;
  const count = 42;
  const intensity = clamp(state.temporalDepth * 1.2 + state.pressure * 0.8, 0, 1);

  ctx.save();
  ctx.globalCompositeOperation = "lighter";

  for (let i = 0; i < count; i++) {
    const p = i / (count - 1);
    const x = lerp(cx - maxR * 0.78, cx + maxR * 0.78, p);
    const h =
      maxR *
      (0.05 +
        0.22 *
          Math.pow(
            Math.sin(p * Math.PI) *
              (0.6 + 0.4 * Math.sin(t * 0.7 + i * 1.9)),
            2
          ) *
          (0.4 + intensity));

    const w = 3 + 11 * Math.pow(Math.sin(p * Math.PI), 2);
    const hue = i % 3;
    ctx.fillStyle =
      hue === 0
        ? `rgba(0,229,255,${0.05 + intensity * 0.18})`
        : hue === 1
        ? `rgba(112,0,255,${0.05 + intensity * 0.16})`
        : `rgba(0,255,102,${0.04 + intensity * 0.14})`;
    ctx.fillRect(x - w / 2, baseY - h, w, h);
  }

  ctx.restore();
}

function drawHUD(t) {
  ctx.save();
  ctx.font = "12px ui-monospace, SFMono-Regular, Menlo, monospace";
  ctx.fillStyle = "rgba(234,247,255,0.55)";

  const lines = [
    "SPIN-THE-CITY // CONE-TIME FIELD",
    "FLOW: Observer → Eye movement → Path through space",
    "STATE: Time through space → Environment manifestations in time",
    `temporalDepth=${state.temporalDepth.toFixed(3)} pressure=${state.pressure.toFixed(3)} spin=${state.spin.toFixed(3)}`
  ];

  const x = 18;
  let y = 24;
  for (const line of lines) {
    ctx.fillText(line, x, y);
    y += 17;
  }

  ctx.restore();
}

function frame(now) {
  const t = now / 1000;
  const dt = Math.min(0.05, t - state.time || 0.016);
  state.time = t;

  const cx = W * 0.5;
  const cy = H * 0.47;
  const maxR = Math.min(W, H) * 0.43;

  const gx = gaze.x * W;
  const gy = gaze.y * H;
  const dx = gx - cx;
  const dy = gy - cy;
  const gazeR = Math.hypot(dx, dy);
  const gazeRNorm = clamp(gazeR / Math.max(1, maxR), 0, 1);
  const gazeAngle = Math.atan2(dy, dx);

  const idleMs = performance.now() - gaze.lastMove;
  gaze.dwell = clamp(idleMs / 2200, 0, 1);

  state.temporalDepth = lerp(state.temporalDepth, gazeRNorm, 0.055);
  state.pressure = lerp(
    state.pressure,
    clamp(gaze.speed * 38 + gaze.dwell * 0.22, 0, 1),
    0.08
  );
  state.spin = lerp(
    state.spin,
    clamp(state.temporalDepth * 0.65 + state.pressure * 0.75, 0, 1),
    0.06
  );

  ctx.clearRect(0, 0, W, H);
  drawBackground(cx, cy, maxR);
  drawConeSkeleton(cx, cy, maxR, t);

  // 60 cone-time layers, grouped visually so it is legible.
  for (let layer = 1; layer <= 60; layer++) {
    if (layer % 3 !== 0 && layer < 54) continue;
    const r = coneRadius(layer, maxR);
    drawRing(cx, cy, r, layer, t * (0.65 + state.spin * 1.8), gazeAngle, gazeRNorm);
  }

  drawCityManifestation(cx, cy, maxR, t);
  drawRoute(cx, cy, maxR);
  drawHUD(t);

  requestAnimationFrame(frame);
}

requestAnimationFrame(frame);
EOF

echo
echo "== verify source =="
grep -q "SPIN-THE-CITY // CONE-TIME FIELD" "$TARGET"
grep -q "coneTime" "$TARGET"
grep -q "Path through space" "$TARGET"
echo "PASS cone-time-source"
echo "target: $TARGET"
echo "backup: $BACKUP"

echo
echo "== run =="
cd "$APP"

if [[ -f package.json ]]; then
  if command -v pnpm >/dev/null 2>&1; then
    pnpm tauri dev
  else
    npm run tauri dev
  fi
else
  echo "WARN no package.json; build manually from app dir"
fi
