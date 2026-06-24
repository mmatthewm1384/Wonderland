#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Workshop/apps/tauri/wl-spin-city"
ENGINE="$APP/src/matrix/cone-time-engine.js"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$ENGINE.backup.eye-trajectory-recorder-v1.$STAMP"

cp -a "$ENGINE" "$BACKUP"

python3 - <<'PY'
from pathlib import Path

p = Path("src/matrix/cone-time-engine.js")
s = p.read_text()

s = s.replace(
'''      route: [],
    };''',
'''      route: [],
      radialDepth: 0,
      angle: 0,
      radialVelocity: 0,
      angularVelocity: 0,
      curvature: 0,
    };'''
)

s = s.replace(
'''    this.gaze.route.push({ x: nx, y: ny, t: performance.now() });
    if (this.gaze.route.length > 180) this.gaze.route.shift();''',
'''    const now = performance.now();
    const cx = 0.5;
    const cy = 0.5;
    const rx = nx - cx;
    const ry = ny - cy;
    const radialDepth = clamp(Math.hypot(rx, ry) * 2, 0, 1);
    const angle = Math.atan2(ry, rx);

    const prev = this.gaze.route[this.gaze.route.length - 1];
    const radialVelocity = prev ? radialDepth - prev.radialDepth : 0;
    const angularVelocity = prev ? angle - prev.angle : 0;

    this.gaze.radialDepth = radialDepth;
    this.gaze.angle = angle;
    this.gaze.radialVelocity = radialVelocity;
    this.gaze.angularVelocity = angularVelocity;

    this.gaze.route.push({
      x: nx,
      y: ny,
      t: now,
      radialDepth,
      angle,
      speed: this.gaze.speed,
      radialVelocity,
      angularVelocity
    });

    this.gaze.route = this.gaze.route.filter(p => now - p.t <= 5000);'''
)

marker = "  tick(time) {"
insert = r'''
  solveTrajectoryMetrics() {
    const route = this.gaze.route;
    if (route.length < 4) {
      this.gaze.curvature = 0;
      return;
    }

    let bend = 0;
    let samples = 0;

    for (let i = 2; i < route.length; i++) {
      const a = route[i - 2];
      const b = route[i - 1];
      const c = route[i];

      const v1x = b.x - a.x;
      const v1y = b.y - a.y;
      const v2x = c.x - b.x;
      const v2y = c.y - b.y;

      const m1 = Math.hypot(v1x, v1y);
      const m2 = Math.hypot(v2x, v2y);
      if (m1 < 0.0001 || m2 < 0.0001) continue;

      const dot = clamp((v1x * v2x + v1y * v2y) / (m1 * m2), -1, 1);
      bend += Math.acos(dot) / Math.PI;
      samples++;
    }

    this.gaze.curvature = samples ? clamp(bend / samples, 0, 1) : 0;
  }

'''
if "solveTrajectoryMetrics" not in s:
    s = s.replace(marker, insert + marker)

s = s.replace(
'''    this.state.spin = lerp(
      this.state.spin,
      clamp(this.state.temporalDepth * 0.65 + this.state.pressure * 0.75, 0, 1),
      0.06
    );

    this.lastTime = time;''',
'''    this.solveTrajectoryMetrics();

    this.state.spin = lerp(
      this.state.spin,
      clamp(
        this.state.temporalDepth * 0.65 +
        this.state.pressure * 0.75 +
        this.gaze.curvature * 0.35,
        0,
        1
      ),
      0.06
    );

    this.lastTime = time;'''
)

s = s.replace(
'''    ctx.strokeStyle = "rgba(0,229,255,0.35)";
    ctx.lineWidth = 1.6;
    ctx.beginPath();

    for (let i = 0; i < this.gaze.route.length; i++) {
      const p = this.gaze.route[i];
      const x = p.x * this.width;
      const y = p.y * this.height;
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }

    ctx.stroke();''',
'''    const now = performance.now();

    for (let i = 1; i < this.gaze.route.length; i++) {
      const a = this.gaze.route[i - 1];
      const b = this.gaze.route[i];
      const age = clamp((now - b.t) / 5000, 0, 1);
      const alpha = 0.42 * (1 - age);
      const width = 1.0 + b.speed * 80 + b.curvature * 2;

      ctx.strokeStyle =
        age < 0.35
          ? `rgba(0,229,255,${alpha})`
          : `rgba(112,0,255,${alpha * 0.8})`;

      ctx.lineWidth = width;
      ctx.beginPath();
      ctx.moveTo(a.x * this.width, a.y * this.height);
      ctx.lineTo(b.x * this.width, b.y * this.height);
      ctx.stroke();
    }'''
)

s = s.replace(
'''      `depth=${this.state.temporalDepth.toFixed(3)} pressure=${this.state.pressure.toFixed(3)} spin=${this.state.spin.toFixed(3)}`''',
'''      `depth=${this.state.temporalDepth.toFixed(3)} pressure=${this.state.pressure.toFixed(3)} spin=${this.state.spin.toFixed(3)}`,
      `route=${this.gaze.route.length} radialV=${this.gaze.radialVelocity.toFixed(3)} angularV=${this.gaze.angularVelocity.toFixed(3)} curvature=${this.gaze.curvature.toFixed(3)}`'''
)

p.write_text(s)
print("PASS eye-trajectory-recorder-v1-patched")
PY

node --check "$ENGINE"
grep -n "solveTrajectoryMetrics\|radialVelocity\|angularVelocity\|curvature\|route=" "$ENGINE"

echo "backup: $BACKUP"
