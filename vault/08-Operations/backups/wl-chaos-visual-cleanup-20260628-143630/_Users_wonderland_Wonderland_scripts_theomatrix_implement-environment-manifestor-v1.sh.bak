#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Workshop/apps/tauri/wl-spin-city"
ENGINE="$APP/src/matrix/cone-time-engine.js"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$ENGINE.backup.environment-manifestor-v1.$STAMP"

cp -a "$ENGINE" "$BACKUP"

python3 - <<'PY'
from pathlib import Path

p = Path("src/matrix/cone-time-engine.js")
s = p.read_text()

old = '''  drawManifestation(ctx, cx, cy, maxR, t) {
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
  }'''

new = '''  drawManifestation(ctx, cx, cy, maxR, t) {
    const baseY = cy + maxR * 0.58;

    const depth = this.state.temporalDepth;
    const pressure = this.state.pressure;
    const focus = this.state.focus;
    const coherence = this.state.coherence;
    const agitation = this.state.agitation;
    const expansion = this.state.expansion;
    const contraction = this.state.contraction;

    const count = Math.floor(34 + pressure * 36 + expansion * 18);
    const horizon = maxR * (0.62 + expansion * 0.24 - contraction * 0.10);
    const order = 0.35 + coherence * 0.65;
    const heightBoost = 0.08 + depth * 0.22 + pressure * 0.18;
    const motion = agitation * 1.8 + pressure * 0.8;

    ctx.save();
    ctx.globalCompositeOperation = "lighter";

    // horizon field
    ctx.strokeStyle = `rgba(0,229,255,${0.06 + expansion * 0.18 + focus * 0.10})`;
    ctx.lineWidth = 1 + expansion * 2;
    ctx.beginPath();
    ctx.ellipse(cx, baseY, horizon, maxR * (0.10 + depth * 0.05), 0, 0, Math.PI * 2);
    ctx.stroke();

    // manifested architecture
    for (let i = 0; i < count; i++) {
      const p = count <= 1 ? 0 : i / (count - 1);
      const centered = p - 0.5;
      const x = cx + centered * horizon * 1.82;
      const curve = Math.pow(Math.sin(p * Math.PI), 2);

      const orderedWave = Math.sin(i * 0.85) * (1 - order);
      const activeWave = Math.sin(t * (0.55 + motion) + i * (0.7 + agitation)) * (0.35 + agitation);

      const bh = maxR * curve * heightBoost * (0.7 + orderedWave * 0.25 + activeWave * 0.18);
      const bw = 2 + 12 * curve * (0.45 + focus * 0.55);

      const alpha = 0.05 + pressure * 0.12 + focus * 0.10 + coherence * 0.07;

      ctx.fillStyle =
        i % 3 === 0
          ? `rgba(0,229,255,${alpha})`
          : i % 3 === 1
          ? `rgba(112,0,255,${alpha * 0.90})`
          : `rgba(0,255,102,${alpha * 0.82})`;

      ctx.fillRect(x - bw / 2, baseY - bh, bw, bh);

      if (focus > 0.18 && i % 4 === 0) {
        ctx.fillStyle = `rgba(234,247,255,${0.04 + focus * 0.16})`;
        ctx.fillRect(x - bw / 2, baseY - bh, bw, Math.max(1, bh * 0.08));
      }
    }

    // pressure glow
    if (pressure > 0.08) {
      const g = ctx.createRadialGradient(cx, baseY, 0, cx, baseY, maxR * (0.35 + pressure));
      g.addColorStop(0, `rgba(112,0,255,${0.04 + pressure * 0.12})`);
      g.addColorStop(1, "rgba(112,0,255,0)");
      ctx.fillStyle = g;
      ctx.fillRect(0, 0, this.width, this.height);
    }

    ctx.restore();
  }'''

if old not in s:
    raise SystemExit("FAIL drawManifestation block not found")

s = s.replace(old, new)

p.write_text(s)
print("PASS environment-manifestor-v1-patched")
PY

node --check "$ENGINE"
grep -n "drawManifestation\|horizon field\|manifested architecture\|pressure glow" "$ENGINE"

echo "backup: $BACKUP"
