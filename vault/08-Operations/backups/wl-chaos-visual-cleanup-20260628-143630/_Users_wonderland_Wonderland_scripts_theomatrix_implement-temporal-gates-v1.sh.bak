#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Workshop/apps/tauri/wl-spin-city"
ENGINE="$APP/src/matrix/cone-time-engine.js"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$ENGINE.backup.temporal-gates-v1.$STAMP"

cp -a "$ENGINE" "$BACKUP"

python3 - <<'PY'
from pathlib import Path

p = Path("src/matrix/cone-time-engine.js")
s = p.read_text()

# Add gate state in constructor
s = s.replace(
'''    this.state = {
      temporalDepth: 0,
      pressure: 0,
      spin: 0,
    };''',
'''    this.state = {
      temporalDepth: 0,
      pressure: 0,
      spin: 0,
      gateCrossings: 0,
      gatePressure: 0,
      gateCoherence: 0,
    };

    this.gates = [];'''
)

# Add gate solver before tick()
marker = "  tick(time) {"
insert = r'''
  solveTemporalGates(t, maxR) {
    this.gates = [];

    for (let layer = 3; layer <= 60; layer += 3) {
      const inner = layer - 3;
      if (inner <= 0) continue;

      const r1 = this.coneRadius(inner, maxR);
      const r2 = this.coneRadius(layer, maxR);
      const depth = layer / 60;

      const dirA = ROTATION_PATTERN[(inner - 1) % ROTATION_PATTERN.length];
      const dirB = ROTATION_PATTERN[(layer - 1) % ROTATION_PATTERN.length];

      const phaseA = dirA * t * (0.08 + 0.85 / Math.sqrt(inner + 1));
      const phaseB = dirB * t * (0.08 + 0.85 / Math.sqrt(layer + 1));

      const gates = Math.floor(2 + depth * 10);

      for (let i = 0; i < gates; i++) {
        const base = (i / gates) * Math.PI * 2;
        const delta = Math.abs(Math.sin((phaseA - phaseB) + base));
        const alignment = 1 - delta;

        if (alignment < 0.72) continue;

        const angle = base + (phaseA + phaseB) * 0.5;
        const radius = (r1 + r2) * 0.5;
        const width = 0.025 + alignment * 0.055;
        const strength = alignment * (0.35 + depth * 0.65);

        this.gates.push({
          ringA: inner,
          ringB: layer,
          angle,
          radius,
          width,
          strength,
          lifetime: alignment,
          stability: 1 - Math.abs(dirA - dirB) * 0.22,
          type: alignment > 0.9 ? "corridor" : "alignment",
        });
      }
    }
  }

'''
if marker in s and "solveTemporalGates" not in s:
    s = s.replace(marker, insert + marker)

# Call solver in tick()
s = s.replace(
'''    this.state.spin = lerp(
      this.state.spin,
      clamp(this.state.temporalDepth * 0.65 + this.state.pressure * 0.75, 0, 1),
      0.06
    );

    this.lastTime = time;''',
'''    this.state.spin = lerp(
      this.state.spin,
      clamp(this.state.temporalDepth * 0.65 + this.state.pressure * 0.75, 0, 1),
      0.06
    );

    this.solveTemporalGates(time / 1000, maxR);

    const gatePressure = clamp(this.gates.reduce((a, g) => a + g.strength, 0) / 12, 0, 1);
    const gateCoherence = clamp(this.gates.filter(g => g.type === "corridor").length / 8, 0, 1);

    this.state.gatePressure = lerp(this.state.gatePressure, gatePressure, 0.05);
    this.state.gateCoherence = lerp(this.state.gateCoherence, gateCoherence, 0.05);

    this.lastTime = time;'''
)

# Add draw call after rings
s = s.replace(
'''    this.drawManifestation(ctx, cx, cy, maxR, t);''',
'''    this.drawTemporalGates(ctx, cx, cy, t);
    this.drawManifestation(ctx, cx, cy, maxR, t);'''
)

# Add renderer before drawRoute
marker = "  drawRoute(ctx) {"
insert = r'''
  drawTemporalGates(ctx, cx, cy, t) {
    if (!this.gates.length) return;

    ctx.save();
    ctx.globalCompositeOperation = "lighter";

    for (const g of this.gates) {
      const yScale = 0.52 + (g.ringB / 60) * 0.32;
      const a = g.angle;
      const spread = g.width;
      const r = g.radius;

      const x1 = cx + Math.cos(a - spread) * r;
      const y1 = cy + Math.sin(a - spread) * r * yScale;
      const x2 = cx + Math.cos(a + spread) * r;
      const y2 = cy + Math.sin(a + spread) * r * yScale;

      const alpha = 0.08 + g.strength * 0.42;
      ctx.strokeStyle =
        g.type === "corridor"
          ? `rgba(0,255,102,${alpha})`
          : `rgba(0,229,255,${alpha})`;

      ctx.lineWidth = 1.0 + g.strength * 3.5;
      ctx.beginPath();
      ctx.moveTo(x1, y1);
      ctx.quadraticCurveTo(
        cx + Math.cos(a) * r * 1.02,
        cy + Math.sin(a) * r * yScale * 1.02,
        x2,
        y2
      );
      ctx.stroke();

      ctx.fillStyle = `rgba(234,247,255,${0.05 + g.strength * 0.22})`;
      ctx.beginPath();
      ctx.arc(
        cx + Math.cos(a) * r,
        cy + Math.sin(a) * r * yScale,
        1.5 + g.strength * 3.5,
        0,
        Math.PI * 2
      );
      ctx.fill();
    }

    ctx.restore();
  }

'''
if marker in s and "drawTemporalGates" not in s:
    s = s.replace(marker, insert + marker)

# HUD update
s = s.replace(
'''      `depth=${this.state.temporalDepth.toFixed(3)} pressure=${this.state.pressure.toFixed(3)} spin=${this.state.spin.toFixed(3)}`''',
'''      `depth=${this.state.temporalDepth.toFixed(3)} pressure=${this.state.pressure.toFixed(3)} spin=${this.state.spin.toFixed(3)}`,
      `gates=${this.gates.length} gatePressure=${this.state.gatePressure.toFixed(3)} coherence=${this.state.gateCoherence.toFixed(3)}`'''
)

p.write_text(s)
print("PASS temporal-gates-v1-patched")
PY

grep -n "solveTemporalGates\|drawTemporalGates\|gatePressure\|gateCoherence" "$ENGINE"

echo "backup: $BACKUP"
