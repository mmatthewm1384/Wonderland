#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Workshop/apps/tauri/wl-spin-city"
ENGINE="$APP/src/matrix/cone-time-engine.js"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$ENGINE.backup.living-ring-deformation-v1.$STAMP"

cp -a "$ENGINE" "$BACKUP"

python3 - <<'PY'
from pathlib import Path

p = Path("src/matrix/cone-time-engine.js")
s = p.read_text()

old = '''      const wave =
        1 +
        Math.sin(a * 3 + phase * 2.1) * 0.018 +
        Math.sin(a * 8 - phase * 1.4) * 0.012 +
        influence * Math.cos(a - gazeA - phase) * 0.11;'''

new = '''      const pressureWarp = this.state.pressure * 0.045;
      const focusCalm = this.state.focus * 0.020;
      const agitationWarp = this.state.agitation * 0.060;
      const coherenceOrder = this.state.coherence * 0.018;
      const expansionPull = this.state.expansion * 0.040;
      const contractionPull = this.state.contraction * 0.035;

      const wave =
        1 +
        Math.sin(a * 3 + phase * 2.1) * (0.014 + coherenceOrder) +
        Math.sin(a * 8 - phase * 1.4) * (0.008 + agitationWarp) +
        Math.sin(a * 13 + t * 0.7 + layer) * pressureWarp +
        influence * Math.cos(a - gazeA - phase) * (0.08 + expansionPull) -
        focusCalm +
        contractionPull * Math.cos(a * 2 - phase);'''

if old not in s:
    raise SystemExit("FAIL ring wave block not found")

s = s.replace(old, new)

p.write_text(s)
print("PASS living-ring-deformation-v1-patched")
PY

node --check "$ENGINE"
grep -n "pressureWarp\|focusCalm\|agitationWarp\|coherenceOrder\|expansionPull\|contractionPull" "$ENGINE"

echo "backup: $BACKUP"
