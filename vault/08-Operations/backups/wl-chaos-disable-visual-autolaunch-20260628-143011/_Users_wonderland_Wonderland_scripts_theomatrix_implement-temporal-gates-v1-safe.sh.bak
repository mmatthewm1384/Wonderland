#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Workshop/apps/tauri/wl-spin-city"
ENGINE="$APP/src/matrix/cone-time-engine.js"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$ENGINE.backup.temporal-gates-v1-safe.$STAMP"

cp -a "$ENGINE" "$BACKUP"

python3 - <<'PY'
from pathlib import Path

p = Path("src/matrix/cone-time-engine.js")
s = p.read_text()

s = s.replace(
'''    this.gaze = {''',
'''    this.gates = [];

    this.gaze = {'''
)

insert = r'''
  solveTemporalGates(t, maxR) {
    this.gates = [];

    for (let layer = 6; layer <= 60; layer += 3) {
      const inner = layer - 3;
      const depth = layer / 60;

      const r1 = this.coneRadius(inner, maxR);
      const r2 = this.coneRadius(layer, maxR);
      const radius = (r1 + r2) * 0.5;

      const dirA = ROTATION_PATTERN[(inner - 1) % ROTATION_PATTERN.length];
      const dirB = ROTATION_PATTERN[(layer - 1) % ROTATION_PATTERN.length];

      const phaseA = dirA * t * (0.08 + 0.85 / Math.sqrt(inner + 1));
      const phaseB = dirB * t * (0.08 + 0.85 / Math.sqrt(layer + 1));

      const count = Math.floor(2 + depth * 10);

      for (let i = 0; i < count; i++) {
        const base = (i / count) * Math.PI * 2;
        const alignment = 0.5 + 0.5 * Math.cos((phaseA - phaseB) + base * 2);

        if (alignment < 0.78) continue;

        this.gates.push({
          ringA: inner,
          ringB: layer,
          angle: base + (phaseA + phaseB) * 0.5,
          radius,
          strength: alignment * (0.35 + depth * 0.65),
          width: 0.02 + alignment * 0.06,
          type: alignment > 0.92 ? "corridor" : "alignment"
        });
      }
    }
  }

'''
s = s.replace("  tick(time) {", insert + "\n  tick(time) {", 1)

s = s.replace(
'''    this.solveTemporalState();

    this.lastTime = time;''',
'''    this.solveTemporalState();
    this.solveTemporalGates(time / 1000, maxR);

    this.lastTime = time;'''
)

renderer = r'''
  drawTemporalGates(ctx, cx, cy) {
    if (!this.gates.length) return;

    ctx.save();
    ctx.globalCompositeOperation = "lighter";

    for (const g of this.gates) {
      const yScale = 0.52 + (g.ringB / 60) * 0.32;
      const x = cx + Math.cos(g.angle) * g.radius;
      const y = cy + Math.sin(g.angle) * g.radius * yScale;

      ctx.strokeStyle =
        g.type === "corridor"
          ? `rgba(0,255,102,${0.08 + g.strength * 0.34})`
          : `rgba(0,229,255,${0.07 + g.strength * 0.28})`;

      ctx.lineWidth = 1 + g.strength * 3;

      ctx.beginPath();
      ctx.arc(x, y, 4 + g.strength * 9, 0, Math.PI * 2);
      ctx.stroke();

      ctx.fillStyle = `rgba(234,247,255,${0.04 + g.strength * 0.18})`;
      ctx.beginPath();
      ctx.arc(x, y, 1.5 + g.strength * 3, 0, Math.PI * 2);
      ctx.fill();
    }

    ctx.restore();
  }

'''
s = s.replace("  drawRoute(ctx) {", renderer + "\n  drawRoute(ctx) {", 1)

s = s.replace(
'''    this.drawManifestation(ctx, cx, cy, maxR, t);''',
'''    this.drawTemporalGates(ctx, cx, cy);
    this.drawManifestation(ctx, cx, cy, maxR, t);''',
1
)

s = s.replace(
'''      `expansion=${this.state.expansion.toFixed(3)} contraction=${this.state.contraction.toFixed(3)}`,''',
'''      `expansion=${this.state.expansion.toFixed(3)} contraction=${this.state.contraction.toFixed(3)}`,
      `gates=${this.gates.length}`,'''
)

p.write_text(s)
print("PASS temporal-gates-v1-safe-patched")
PY

node --check "$ENGINE"
grep -n "solveTemporalGates\|drawTemporalGates\|gates=" "$ENGINE"
echo "backup: $BACKUP"
