#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Workshop/apps/tauri/wl-spin-city"
ENGINE="$APP/src/matrix/spin-city-engine.js"
CONE="$APP/src/matrix/cone-time-engine.js"
INDEX="$APP/src/index.html"
STAMP="$(date +%Y%m%d-%H%M%S)"
FREEZE="$APP/src/matrix/spin-city-engine.js.frozen.$STAMP"
INDEX_BAK="$APP/src/index.html.backup.cone-time.$STAMP"

echo "== freeze current spin-city engine =="
cp -a "$ENGINE" "$FREEZE"
cp -a "$INDEX" "$INDEX_BAK"

cat > "$CONE" <<'EOF'
const WL = {
  bg: "#05070A",
  cyan: "#00E5FF",
  purple: "#7000FF",
  green: "#00FF66",
  amber: "#FFB000",
  white: "#EAF7FF",
  gray: "#5E6773",
};

const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
const lerp = (a, b, t) => a + (b - a) * t;

function smoothstep(edge0, edge1, x) {
  const t = clamp((x - edge0) / (edge1 - edge0), 0, 1);
  return t * t * (3 - 2 * t);
}

export class ConeTimeEngine {
  constructor(width, height) {
    this.width = width;
    this.height = height;
    this.cx = width / 2;
    this.cy = height / 2;
    this.lastTime = 0;

    this.gaze = {
      x: 0.5,
      y: 0.5,
      speed: 0,
      dwell: 0,
      lastMove: performance.now(),
      route: [],
    };

    this.state = {
      temporalDepth: 0,
      pressure: 0,
      spin: 0,
    };

    window.addEventListener("pointermove", (e) => this.pointer(e), { passive: true });
  }

  resize(width, height) {
    this.width = width;
    this.height = height;
    this.cx = width / 2;
    this.cy = height / 2;
  }

  pointer(e) {
    const nx = clamp(e.clientX / window.innerWidth, 0, 1);
    const ny = clamp(e.clientY / window.innerHeight, 0, 1);
    const dx = nx - this.gaze.x;
    const dy = ny - this.gaze.y;

    this.gaze.speed = Math.hypot(dx, dy);
    this.gaze.x = nx;
    this.gaze.y = ny;
    this.gaze.lastMove = performance.now();

    this.gaze.route.push({ x: nx, y: ny, t: performance.now() });
    if (this.gaze.route.length > 180) this.gaze.route.shift();
  }

  coneRadius(layer, maxR) {
    const n = layer / 60;
    return maxR * Math.pow(n, 1.35);
  }

  coneTime(layer) {
    return Math.pow(1440, layer / 60);
  }

  tick(time) {
    const maxR = Math.min(this.width, this.height) * 0.43;
    const gx = this.gaze.x * this.width;
    const gy = this.gaze.y * this.height;
    const dx = gx - this.cx;
    const dy = gy - this.cy;
    const gazeRNorm = clamp(Math.hypot(dx, dy) / Math.max(1, maxR), 0, 1);

    const idle = performance.now() - this.gaze.lastMove;
    this.gaze.dwell = clamp(idle / 2200, 0, 1);

    this.state.temporalDepth = lerp(this.state.temporalDepth, gazeRNorm, 0.06);
    this.state.pressure = lerp(
      this.state.pressure,
      clamp(this.gaze.speed * 42 + this.gaze.dwell * 0.2, 0, 1),
      0.08
    );
    this.state.spin = lerp(
      this.state.spin,
      clamp(this.state.temporalDepth * 0.65 + this.state.pressure * 0.75, 0, 1),
      0.06
    );

    this.lastTime = time;
  }

  draw(ctx) {
    const t = this.lastTime / 1000;
    const w = this.width;
    const h = this.height;
    const cx = this.cx;
    const cy = this.cy * 0.94;
    const maxR = Math.min(w, h) * 0.43;

    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.fillStyle = WL.bg;
    ctx.fillRect(0, 0, w, h);

    this.drawBackground(ctx, cx, cy, maxR);
    this.drawConeSkeleton(ctx, cx, cy, maxR, t);

    const gx = this.gaze.x * w;
    const gy = this.gaze.y * h;
    const gazeA = Math.atan2(gy - cy, gx - cx);
    const gazeRN = clamp(Math.hypot(gx - cx, gy - cy) / Math.max(1, maxR), 0, 1);

    for (let layer = 1; layer <= 60; layer++) {
      if (layer % 3 !== 0 && layer < 54) continue;
      this.drawRing(ctx, cx, cy, this.coneRadius(layer, maxR), layer, t, gazeA, gazeRN);
    }

    this.drawManifestation(ctx, cx, cy, maxR, t);
    this.drawRoute(ctx);
    this.drawHud(ctx);
  }

  drawBackground(ctx, cx, cy, maxR) {
    const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, maxR * 1.45);
    g.addColorStop(0.0, "rgba(0,229,255,0.15)");
    g.addColorStop(0.28, "rgba(112,0,255,0.12)");
    g.addColorStop(0.68, "rgba(0,255,102,0.04)");
    g.addColorStop(1.0, "rgba(5,7,10,0.98)");
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, this.width, this.height);
  }

  drawConeSkeleton(ctx, cx, cy, maxR, t) {
    ctx.save();
    ctx.globalCompositeOperation = "lighter";
    for (let i = 0; i < 32; i++) {
      const a = (i / 32) * Math.PI * 2 + t * 0.025;
      ctx.strokeStyle = i % 2 ? "rgba(112,0,255,0.12)" : "rgba(0,229,255,0.15)";
      ctx.lineWidth = 0.75;
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.lineTo(cx + Math.cos(a) * maxR, cy + Math.sin(a) * maxR * 0.62);
      ctx.stroke();
    }
    ctx.restore();
  }

  drawRing(ctx, cx, cy, r, layer, t, gazeA, gazeRN) {
    const depth = layer / 60;
    const dir = layer % 2 === 0 ? 1 : -1;
    const phase = dir * t * (0.08 + 0.85 / Math.sqrt(layer + 1)) * (0.7 + this.state.spin * 2.2);
    const influence = smoothstep(0.18, 0.0, Math.abs(gazeRN - depth));
    const yScale = 0.52 + depth * 0.32;

    ctx.save();
    ctx.globalCompositeOperation = "lighter";
    ctx.translate(cx, cy);
    ctx.rotate(phase + layer * 0.31);

    const segs = Math.floor(40 + depth * 100);
    ctx.beginPath();

    for (let i = 0; i <= segs; i++) {
      const p = i / segs;
      const a = p * Math.PI * 2;
      const wave =
        1 +
        Math.sin(a * 3 + phase * 2.1) * 0.018 +
        Math.sin(a * 8 - phase * 1.4) * 0.012 +
        influence * Math.cos(a - gazeA - phase) * 0.11;

      const rr = r * wave;
      const x = Math.cos(a) * rr;
      const y = Math.sin(a) * rr * yScale;
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }

    const alpha = 0.10 + depth * 0.23 + influence * 0.36;
    ctx.strokeStyle =
      layer % 3 === 0
        ? `rgba(0,229,255,${alpha})`
        : layer % 3 === 1
        ? `rgba(112,0,255,${alpha})`
        : `rgba(0,255,102,${alpha})`;

    ctx.lineWidth = 0.8 + depth * 1.4 + influence * 2.0;
    ctx.stroke();

    const gates = Math.floor(2 + depth * 12);
    for (let g = 0; g < gates; g++) {
      const a = (g / gates) * Math.PI * 2 + phase * 0.65;
      const pulse = 0.45 + 0.55 * Math.sin(t * 3 + g + layer);
      ctx.fillStyle = `rgba(234,247,255,${0.05 + pulse * 0.18 + influence * 0.28})`;
      ctx.beginPath();
      ctx.arc(
        Math.cos(a) * r,
        Math.sin(a) * r * yScale,
        1.3 + depth * 3.0 + influence * 2.5,
        0,
        Math.PI * 2
      );
      ctx.fill();
    }

    ctx.restore();
  }

  drawRoute(ctx) {
    if (this.gaze.route.length < 2) return;

    ctx.save();
    ctx.globalCompositeOperation = "lighter";
    ctx.strokeStyle = "rgba(0,229,255,0.35)";
    ctx.lineWidth = 1.6;
    ctx.beginPath();

    for (let i = 0; i < this.gaze.route.length; i++) {
      const p = this.gaze.route[i];
      const x = p.x * this.width;
      const y = p.y * this.height;
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }

    ctx.stroke();

    const h = this.gaze.route[this.gaze.route.length - 1];
    ctx.fillStyle = "rgba(0,255,102,0.70)";
    ctx.beginPath();
    ctx.arc(h.x * this.width, h.y * this.height, 4.5, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }

  drawManifestation(ctx, cx, cy, maxR, t) {
    const baseY = cy + maxR * 0.56;
    const count = 52;
    const intensity = clamp(this.state.temporalDepth * 1.2 + this.state.pressure * 0.9, 0, 1);

    ctx.save();
    ctx.globalCompositeOperation = "lighter";

    for (let i = 0; i < count; i++) {
      const p = i / (count - 1);
      const x = cx - maxR * 0.84 + p * maxR * 1.68;
      const curve = Math.pow(Math.sin(p * Math.PI), 2);
      const bh = maxR * (0.04 + curve * (0.10 + 0.24 * intensity) * (0.65 + 0.35 * Math.sin(t * 0.8 + i)));
      const bw = 2 + 10 * curve;

      ctx.fillStyle =
        i % 3 === 0
          ? `rgba(0,229,255,${0.07 + intensity * 0.18})`
          : i % 3 === 1
          ? `rgba(112,0,255,${0.07 + intensity * 0.16})`
          : `rgba(0,255,102,${0.05 + intensity * 0.14})`;

      ctx.fillRect(x - bw / 2, baseY - bh, bw, bh);
    }

    ctx.restore();
  }

  drawHud(ctx) {
    ctx.save();
    ctx.font = "12px ui-monospace, SFMono-Regular, Menlo, monospace";
    ctx.fillStyle = "rgba(234,247,255,0.66)";
    [
      "SPIN-THE-CITY // CONE-TIME FIELD",
      "Observer → Eye movement → Path through space",
      "State of time through space → Environment manifestations in time",
      `depth=${this.state.temporalDepth.toFixed(3)} pressure=${this.state.pressure.toFixed(3)} spin=${this.state.spin.toFixed(3)}`
    ].forEach((line, i) => ctx.fillText(line, 18, 24 + i * 17));
    ctx.restore();
  }
}
EOF

python3 - <<PY
from pathlib import Path
p = Path("$INDEX")
s = p.read_text()
s = s.replace(
    'import { SpinCityEngine } from "./matrix/spin-city-engine.js";',
    'import { ConeTimeEngine } from "./matrix/cone-time-engine.js";'
)
s = s.replace(
    'if (!engine) engine = new SpinCityEngine(canvas.width, canvas.height);',
    'if (!engine) engine = new ConeTimeEngine(canvas.width, canvas.height);'
)
p.write_text(s)
PY

echo "== verify =="
grep -q "class ConeTimeEngine" "$CONE"
grep -q "CONE-TIME FIELD" "$CONE"
grep -q "ConeTimeEngine" "$INDEX"
python3 - <<PY
from pathlib import Path
idx = Path("$INDEX").read_text()
assert "SpinCityEngine" not in idx
assert "ConeTimeEngine" in idx
print("PASS cone-time-engine-installed")
PY

echo "frozen: $FREEZE"
echo "index backup: $INDEX_BAK"
echo "created: $CONE"
