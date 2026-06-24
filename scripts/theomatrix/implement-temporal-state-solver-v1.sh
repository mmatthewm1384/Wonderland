#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Workshop/apps/tauri/wl-spin-city"
ENGINE="$APP/src/matrix/cone-time-engine.js"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$ENGINE.backup.temporal-state-solver-v1.$STAMP"

cp -a "$ENGINE" "$BACKUP"

python3 - <<'PY'
from pathlib import Path

p = Path("src/matrix/cone-time-engine.js")
s = p.read_text()

s = s.replace(
'''      temporalDepth: 0,
      pressure: 0,
      spin: 0,''',
'''      temporalDepth: 0,
      pressure: 0,
      focus: 0,
      coherence: 0,
      agitation: 0,
      expansion: 0,
      contraction: 0,
      spin: 0,'''
)

marker = "  tick(time) {"
insert = r'''
  solveTemporalState() {
    const speed = clamp(this.gaze.speed * 42, 0, 1);
    const curvature = clamp(this.gaze.curvature, 0, 1);
    const dwell = clamp(this.gaze.dwell, 0, 1);
    const radialV = this.gaze.radialVelocity;

    const agitation = clamp(speed * 0.65 + curvature * 0.75, 0, 1);
    const focus = clamp(dwell * (1 - speed) * (1 - curvature * 0.5), 0, 1);
    const coherence = clamp(1 - agitation + focus * 0.35, 0, 1);
    const expansion = clamp(radialV * 14, 0, 1);
    const contraction = clamp(-radialV * 14, 0, 1);

    this.state.agitation = lerp(this.state.agitation, agitation, 0.08);
    this.state.focus = lerp(this.state.focus, focus, 0.08);
    this.state.coherence = lerp(this.state.coherence, coherence, 0.08);
    this.state.expansion = lerp(this.state.expansion, expansion, 0.08);
    this.state.contraction = lerp(this.state.contraction, contraction, 0.08);

    this.state.pressure = lerp(
      this.state.pressure,
      clamp(agitation * 0.7 + expansion * 0.25 + contraction * 0.35, 0, 1),
      0.08
    );

    this.state.spin = lerp(
      this.state.spin,
      clamp(
        this.state.temporalDepth * 0.45 +
        this.state.pressure * 0.65 +
        this.state.agitation * 0.45 -
        this.state.focus * 0.18,
        0,
        1
      ),
      0.06
    );
  }

'''
if "solveTemporalState()" not in s:
    s = s.replace(marker, insert + marker)

s = s.replace(
'''    this.state.pressure = lerp(
      this.state.pressure,
      clamp(this.gaze.speed * 42 + this.gaze.dwell * 0.2, 0, 1),
      0.08
    );

    this.solveTrajectoryMetrics();

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
    );''',
'''    this.solveTrajectoryMetrics();
    this.solveTemporalState();'''
)

s = s.replace(
'''      `depth=${this.state.temporalDepth.toFixed(3)} pressure=${this.state.pressure.toFixed(3)} spin=${this.state.spin.toFixed(3)}`,''',
'''      `depth=${this.state.temporalDepth.toFixed(3)} pressure=${this.state.pressure.toFixed(3)} spin=${this.state.spin.toFixed(3)}`,
      `focus=${this.state.focus.toFixed(3)} coherence=${this.state.coherence.toFixed(3)} agitation=${this.state.agitation.toFixed(3)}`,
      `expansion=${this.state.expansion.toFixed(3)} contraction=${this.state.contraction.toFixed(3)}`,'''
)

p.write_text(s)
print("PASS temporal-state-solver-v1-patched")
PY

node --check "$ENGINE"
grep -n "solveTemporalState\|focus\|coherence\|agitation\|expansion\|contraction" "$ENGINE"

echo "backup: $BACKUP"
