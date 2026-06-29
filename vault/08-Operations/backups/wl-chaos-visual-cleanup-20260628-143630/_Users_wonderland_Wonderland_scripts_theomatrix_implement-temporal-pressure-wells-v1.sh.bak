#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Workshop/apps/tauri/wl-spin-city"
ENGINE="$APP/src/matrix/cone-time-engine.js"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$ENGINE.backup.temporal-pressure-wells-v1.$STAMP"

cp -a "$ENGINE" "$BACKUP"

python3 - <<'PY'
from pathlib import Path

p = Path("src/matrix/cone-time-engine.js")
s = p.read_text()

s = s.replace(
'''    this.gates = [];

    this.gaze = {''',
'''    this.gates = [];
    this.wells = [];
    this.lastWellAt = 0;

    this.gaze = {'''
)

insert = r'''
  spawnWell(type, strength) {
    const now = performance.now();

    if (now - this.lastWellAt < 450) return;
    this.lastWellAt = now;

    const existing = this.wells.find(w => w.type === type && Math.hypot(w.x - this.gaze.x, w.y - this.gaze.y) < 0.08);
    if (existing) {
      existing.strength = clamp(existing.strength + strength * 0.25, 0, 1);
      existing.age = 0;
      return;
    }

    this.wells.push({
      x: this.gaze.x,
      y: this.gaze.y,
      type,
      strength: clamp(strength, 0, 1),
      radius: type === "focus" ? 0.18 : type === "pressure" ? 0.24 : 0.28,
      age: 0,
      decay: type === "focus" ? 0.055 : type === "pressure" ? 0.075 : 0.065
    });

    if (this.wells.length > 18) this.wells.shift();
  }

  updatePressureWells(dt) {
    if (this.state.focus > 0.65) this.spawnWell("focus", this.state.focus);
    if (this.state.pressure > 0.60) this.spawnWell("pressure", this.state.pressure);
    if (this.state.expansion > 0.55) this.spawnWell("expansion", this.state.expansion);

    for (const w of this.wells) {
      w.age += dt;
      w.strength = clamp(w.strength - w.decay * dt, 0, 1);
    }

    this.wells = this.wells.filter(w => w.strength > 0.015 && w.age < 24);
  }

  wellInfluence(nx, ny) {
    let pull = 0;
    let push = 0;
    let calm = 0;

    for (const w of this.wells) {
      const d = Math.hypot(nx - w.x, ny - w.y);
      const k = clamp(1 - d / w.radius, 0, 1);
      const influence = k * k * w.strength;

      if (w.type === "pressure") pull += influence;
      if (w.type === "expansion") push += influence;
      if (w.type === "focus") calm += influence;
    }

    return {
      pull: clamp(pull, 0, 1),
      push: clamp(push, 0, 1),
      calm: clamp(calm, 0, 1)
    };
  }

'''
s = s.replace("  solveTemporalGates(t, maxR) {", insert + "\n  solveTemporalGates(t, maxR) {", 1)

s = s.replace(
'''    this.solveTemporalState();
    this.solveTemporalGates(time / 1000, maxR);

    this.lastTime = time;''',
'''    this.solveTemporalState();
    this.updatePressureWells(Math.min(0.05, (time - this.lastTime) / 1000 || 0.016));
    this.solveTemporalGates(time / 1000, maxR);

    this.lastTime = time;'''
)

old = '''      const wave =
        1 +
        Math.sin(a * 3 + phase * 2.1) * (0.014 + coherenceOrder) +
        Math.sin(a * 8 - phase * 1.4) * (0.008 + agitationWarp) +
        Math.sin(a * 13 + t * 0.7 + layer) * pressureWarp +
        influence * Math.cos(a - gazeA - phase) * (0.08 + expansionPull) -
        focusCalm +
        contractionPull * Math.cos(a * 2 - phase);

      const rr = r * wave;
      const x = Math.cos(a) * rr;
      const y = Math.sin(a) * rr * yScale;'''

new = '''      const wx = (cx + Math.cos(a + phase) * r) / this.width;
      const wy = (cy + Math.sin(a + phase) * r * yScale) / this.height;
      const well = this.wellInfluence(wx, wy);

      const wave =
        1 +
        Math.sin(a * 3 + phase * 2.1) * (0.014 + coherenceOrder - well.calm * 0.010) +
        Math.sin(a * 8 - phase * 1.4) * (0.008 + agitationWarp + well.pull * 0.035) +
        Math.sin(a * 13 + t * 0.7 + layer) * (pressureWarp + well.pull * 0.040) +
        influence * Math.cos(a - gazeA - phase) * (0.08 + expansionPull + well.push * 0.040) -
        focusCalm -
        well.pull * 0.035 +
        well.push * 0.045 +
        contractionPull * Math.cos(a * 2 - phase);

      const rr = r * wave;
      const x = Math.cos(a) * rr;
      const y = Math.sin(a) * rr * yScale;'''

if old not in s:
    raise SystemExit("FAIL living deformation wave block not found")

s = s.replace(old, new)

renderer = r'''
  drawPressureWells(ctx) {
    if (!this.wells.length) return;

    ctx.save();
    ctx.globalCompositeOperation = "lighter";

    for (const w of this.wells) {
      const x = w.x * this.width;
      const y = w.y * this.height;
      const r = w.radius * Math.min(this.width, this.height) * (0.65 + w.age * 0.025);
      const alpha = 0.05 + w.strength * 0.22;

      const g = ctx.createRadialGradient(x, y, 0, x, y, r);

      if (w.type === "focus") {
        g.addColorStop(0, `rgba(0,229,255,${alpha})`);
        g.addColorStop(1, "rgba(0,229,255,0)");
      } else if (w.type === "pressure") {
        g.addColorStop(0, `rgba(112,0,255,${alpha})`);
        g.addColorStop(1, "rgba(112,0,255,0)");
      } else {
        g.addColorStop(0, `rgba(0,255,102,${alpha})`);
        g.addColorStop(1, "rgba(0,255,102,0)");
      }

      ctx.fillStyle = g;
      ctx.beginPath();
      ctx.arc(x, y, r, 0, Math.PI * 2);
      ctx.fill();

      ctx.strokeStyle =
        w.type === "focus"
          ? `rgba(0,229,255,${0.08 + w.strength * 0.22})`
          : w.type === "pressure"
          ? `rgba(112,0,255,${0.08 + w.strength * 0.22})`
          : `rgba(0,255,102,${0.08 + w.strength * 0.22})`;

      ctx.lineWidth = 1 + w.strength * 2;
      ctx.beginPath();
      ctx.arc(x, y, r * 0.52, 0, Math.PI * 2);
      ctx.stroke();
    }

    ctx.restore();
  }

'''
s = s.replace("  drawTemporalGates(ctx, cx, cy) {", renderer + "\n  drawTemporalGates(ctx, cx, cy) {", 1)

s = s.replace(
'''    this.drawTemporalGates(ctx, cx, cy);
    this.drawManifestation(ctx, cx, cy, maxR, t);''',
'''    this.drawPressureWells(ctx);
    this.drawTemporalGates(ctx, cx, cy);
    this.drawManifestation(ctx, cx, cy, maxR, t);'''
)

s = s.replace(
'''      `gates=${this.gates.length}`,''',
'''      `gates=${this.gates.length} wells=${this.wells.length}`,'''
)

p.write_text(s)
print("PASS temporal-pressure-wells-v1-patched")
PY

node --check "$ENGINE"
grep -n "spawnWell\|updatePressureWells\|wellInfluence\|drawPressureWells\|wells=" "$ENGINE"

echo "backup: $BACKUP"
