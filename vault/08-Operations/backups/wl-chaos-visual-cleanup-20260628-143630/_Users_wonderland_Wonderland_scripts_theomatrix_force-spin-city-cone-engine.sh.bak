#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Workshop/apps/tauri/wl-spin-city"
ENGINE="$APP/src/matrix/spin-city-engine.js"
BACKUP="$ENGINE.backup.cone-time-$(date +%Y%m%d-%H%M%S)"

cp -a "$ENGINE" "$BACKUP"

cat > "$ENGINE" <<'EOF'
export function startSpinCity(canvas) {
  const ctx = canvas.getContext("2d");

  const WL = {
    bg: "#05070A",
    cyan: "#00E5FF",
    purple: "#7000FF",
    green: "#00FF66",
    white: "#EAF7FF"
  };

  let W = 0, H = 0, DPR = 1;

  const gaze = {
    x: 0.5, y: 0.5,
    px: 0.5, py: 0.5,
    speed: 0,
    dwell: 0,
    last: performance.now(),
    route: []
  };

  const state = {
    temporalDepth: 0,
    pressure: 0,
    spin: 0
  };

  function resize() {
    W = window.innerWidth;
    H = window.innerHeight;
    DPR = Math.max(1, window.devicePixelRatio || 1);
    canvas.width = Math.floor(W * DPR);
    canvas.height = Math.floor(H * DPR);
    canvas.style.width = W + "px";
    canvas.style.height = H + "px";
    ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
  }

  function clamp(v, a, b) {
    return Math.max(a, Math.min(b, v));
  }

  function lerp(a, b, t) {
    return a + (b - a) * t;
  }

  function smoothstep(a, b, x) {
    const t = clamp((x - a) / (b - a), 0, 1);
    return t * t * (3 - 2 * t);
  }

  function pointer(e) {
    const nx = clamp(e.clientX / Math.max(1, W), 0, 1);
    const ny = clamp(e.clientY / Math.max(1, H), 0, 1);
    const dx = nx - gaze.x;
    const dy = ny - gaze.y;
    gaze.speed = Math.hypot(dx, dy);
    gaze.px = gaze.x;
    gaze.py = gaze.y;
    gaze.x = nx;
    gaze.y = ny;
    gaze.last = performance.now();
    gaze.route.push({ x: nx, y: ny, t: performance.now() });
    if (gaze.route.length > 160) gaze.route.shift();
  }

  window.addEventListener("resize", resize);
  window.addEventListener("pointermove", pointer, { passive: true });
  resize();

  function coneRadius(layer, maxR) {
    const n = layer / 60;
    return maxR * Math.pow(n, 1.35);
  }

  function coneTime(layer) {
    return Math.pow(1440, layer / 60);
  }

  function bg(cx, cy, maxR) {
    ctx.fillStyle = WL.bg;
    ctx.fillRect(0, 0, W, H);

    const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, maxR * 1.45);
    g.addColorStop(0.00, "rgba(0,229,255,0.16)");
    g.addColorStop(0.28, "rgba(112,0,255,0.12)");
    g.addColorStop(0.62, "rgba(0,255,102,0.04)");
    g.addColorStop(1.00, "rgba(5,7,10,0.96)");
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, W, H);
  }

  function skeleton(cx, cy, maxR, t) {
    ctx.save();
    ctx.globalCompositeOperation = "lighter";

    for (let i = 0; i < 32; i++) {
      const a = (i / 32) * Math.PI * 2 + t * 0.025;
      const x = cx + Math.cos(a) * maxR;
      const y = cy + Math.sin(a) * maxR * 0.62;
      ctx.strokeStyle = i % 2 ? "rgba(112,0,255,0.12)" : "rgba(0,229,255,0.15)";
      ctx.lineWidth = 0.7;
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.lineTo(x, y);
      ctx.stroke();
    }

    ctx.restore();
  }

  function ring(cx, cy, r, layer, t, gazeA, gazeRN) {
    const depth = layer / 60;
    const dir = layer % 2 === 0 ? 1 : -1;
    const phase = dir * t * (0.08 + 0.85 / Math.sqrt(layer + 1)) + layer * 0.31;
    const influence = smoothstep(0.18, 0.0, Math.abs(gazeRN - depth));
    const yScale = 0.52 + depth * 0.32;

    ctx.save();
    ctx.globalCompositeOperation = "lighter";
    ctx.translate(cx, cy);
    ctx.rotate(phase);

    const segs = Math.floor(40 + depth * 100);
    ctx.beginPath();

    for (let i = 0; i <= segs; i++) {
      const p = i / segs;
      const a = p * Math.PI * 2;
      const local =
        1 +
        Math.sin(a * 3 + phase * 2.1) * 0.018 +
        Math.sin(a * 8 - phase * 1.4) * 0.010 +
        influence * Math.cos(a - gazeA - phase) * 0.10;

      const rr = r * local;
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

  function route() {
    if (gaze.route.length < 2) return;

    ctx.save();
    ctx.globalCompositeOperation = "lighter";
    ctx.lineWidth = 1.6;
    ctx.strokeStyle = "rgba(0,229,255,0.35)";
    ctx.beginPath();

    for (let i = 0; i < gaze.route.length; i++) {
      const p = gaze.route[i];
      const x = p.x * W;
      const y = p.y * H;
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }

    ctx.stroke();

    const h = gaze.route[gaze.route.length - 1];
    ctx.fillStyle = "rgba(0,255,102,0.70)";
    ctx.beginPath();
    ctx.arc(h.x * W, h.y * H, 4.5, 0, Math.PI * 2);
    ctx.fill();

    ctx.restore();
  }

  function city(cx, cy, maxR, t) {
    const baseY = cy + maxR * 0.55;
    const count = 48;
    const intensity = clamp(state.temporalDepth * 1.2 + state.pressure * 0.9, 0, 1);

    ctx.save();
    ctx.globalCompositeOperation = "lighter";

    for (let i = 0; i < count; i++) {
      const p = i / (count - 1);
      const x = lerp(cx - maxR * 0.82, cx + maxR * 0.82, p);
      const curve = Math.pow(Math.sin(p * Math.PI), 2);
      const h = maxR * (0.04 + curve * (0.10 + 0.24 * intensity) * (0.65 + 0.35 * Math.sin(t * 0.8 + i)));
      const w = 2 + 10 * curve;

      ctx.fillStyle =
        i % 3 === 0
          ? `rgba(0,229,255,${0.07 + intensity * 0.18})`
          : i % 3 === 1
          ? `rgba(112,0,255,${0.07 + intensity * 0.16})`
          : `rgba(0,255,102,${0.05 + intensity * 0.14})`;

      ctx.fillRect(x - w / 2, baseY - h, w, h);
    }

    ctx.restore();
  }

  function hud() {
    ctx.save();
    ctx.font = "12px ui-monospace, SFMono-Regular, Menlo, monospace";
    ctx.fillStyle = "rgba(234,247,255,0.62)";

    [
      "SPIN-THE-CITY // CONE-TIME FIELD",
      "Observer → Eye movement → Path through space",
      "State of time through space → Environment manifestations in time",
      `depth=${state.temporalDepth.toFixed(3)} pressure=${state.pressure.toFixed(3)} spin=${state.spin.toFixed(3)}`
    ].forEach((line, i) => ctx.fillText(line, 18, 24 + i * 17));

    ctx.restore();
  }

  function frame(now) {
    const t = now / 1000;
    const cx = W * 0.5;
    const cy = H * 0.46;
    const maxR = Math.min(W, H) * 0.43;

    const gx = gaze.x * W;
    const gy = gaze.y * H;
    const dx = gx - cx;
    const dy = gy - cy;
    const gazeRN = clamp(Math.hypot(dx, dy) / Math.max(1, maxR), 0, 1);
    const gazeA = Math.atan2(dy, dx);

    const idle = performance.now() - gaze.last;
    gaze.dwell = clamp(idle / 2200, 0, 1);

    state.temporalDepth = lerp(state.temporalDepth, gazeRN, 0.06);
    state.pressure = lerp(state.pressure, clamp(gaze.speed * 42 + gaze.dwell * 0.2, 0, 1), 0.08);
    state.spin = lerp(state.spin, clamp(state.temporalDepth * 0.65 + state.pressure * 0.75, 0, 1), 0.06);

    bg(cx, cy, maxR);
    skeleton(cx, cy, maxR, t);

    for (let layer = 1; layer <= 60; layer++) {
      if (layer % 3 !== 0 && layer < 54) continue;
      ring(cx, cy, coneRadius(layer, maxR), layer, t * (0.65 + state.spin * 1.9), gazeA, gazeRN);
    }

    city(cx, cy, maxR, t);
    route();
    hud();

    requestAnimationFrame(frame);
  }

  requestAnimationFrame(frame);
}

export default startSpinCity;
EOF

echo "== verify =="
grep -q "SPIN-THE-CITY // CONE-TIME FIELD" "$ENGINE"
grep -q "coneTime" "$ENGINE"
grep -q "State of time through space" "$ENGINE"
echo "PASS cone-time-engine"
echo "backup: $BACKUP"
