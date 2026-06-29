#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APPS="$ROOT/apps/tauri"
SHARED="$ROOT/apps/shared/chaos"
REPORT="$ROOT/vault/08-Operations/reports/js-chaos-contract-drop-in-report.txt"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$SHARED" "$(dirname "$REPORT")"

cat > "$SHARED/contract-loader.js" <<'JS'
export async function loadChaosContract() {
  const candidates = [
    window.WL_CHAOS_CONTRACT,
    "file:///Users/wonderland/Wonderland/vault/chaos/visual-chaos-contract.json",
  ].filter(Boolean);

  for (const path of candidates) {
    try {
      const response = await fetch(`${path}?t=${Date.now()}`, { cache: "no-store" });
      if (response.ok) return await response.json();
    } catch {}
  }

  return null;
}

export async function chaosConfig(appName) {
  const contract = await loadChaosContract();
  if (!contract || !contract.chaos_active) return null;
  return contract.apps?.[appName] ?? null;
}
JS

: > "$REPORT"

log() {
  echo "$*" | tee -a "$REPORT"
}

backup() {
  local f="$1"
  cp "$f" "$f.backup.$STAMP"
}

patch_agitate() {
  local f="$APPS/wl-agitate/src/main.js"
  [[ -f "$f" ]] || { log "WARN missing $f"; return; }

  if grep -q "WL_CHAOS_DROP_IN_AGITATE" "$f"; then
    log "PASS wl-agitate already patched"
    return
  fi

  backup "$f"

  python3 - "$f" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

inject = r'''
// WL_CHAOS_DROP_IN_AGITATE
async function loadChaosContract() {
  try {
    const response = await fetch("file:///Users/wonderland/Wonderland/vault/chaos/visual-chaos-contract.json?t=" + Date.now(), { cache: "no-store" });
    return await response.json();
  } catch {
    return null;
  }
}

async function applyChaosContract() {
  const contract = await loadChaosContract();
  const cfg = contract?.chaos_active ? contract?.apps?.["wl-agitate"] : null;

  if (cfg) {
    settings.density = Math.max(settings.density, Math.round((cfg.intensity ?? 2.0) * 60));
    settings.speed = Math.max(settings.speed, 0.55);
    settings.glow = Math.max(settings.glow, 1.25);
    settings.tension = Math.max(settings.tension, 2.2);
    if (typeof presetName !== "undefined") presetName.textContent = "MODE: CHAOS";
  } else {
    Object.assign(settings, presets.ambient);
    if (typeof presetName !== "undefined") presetName.textContent = "MODE: ambient";
  }

  sync();
}

setInterval(applyChaosContract, 30000);
window.addEventListener("focus", applyChaosContract);
document.addEventListener("visibilitychange", applyChaosContract);
'''

s += "\n" + inject + "\napplyChaosContract();\n"
p.write_text(s)
PY

  log "PASS patched wl-agitate main.js"
}

patch_matrix() {
  local f="$APPS/wl-matrix/src/main.js"
  [[ -f "$f" ]] || { log "WARN missing $f"; return; }

  if grep -q "WL_CHAOS_DROP_IN_MATRIX" "$f"; then
    log "PASS wl-matrix already patched"
    return
  fi

  backup "$f"

  python3 - "$f" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

inject = r'''
// WL_CHAOS_DROP_IN_MATRIX
async function loadChaosContract() {
  try {
    const response = await fetch("file:///Users/wonderland/Wonderland/vault/chaos/visual-chaos-contract.json?t=" + Date.now(), { cache: "no-store" });
    return await response.json();
  } catch {
    return null;
  }
}

async function applyChaosContract() {
  const contract = await loadChaosContract();
  const cfg = contract?.chaos_active ? contract?.apps?.["wl-matrix"] : null;

  if (cfg) {
    settings.density = Math.max(settings.density, Math.round((cfg.particles ?? 10000) / 45));
    settings.speed = Math.max(settings.speed, 0.9);
    settings.glow = Math.max(settings.glow, 1.4);
    settings.chaos = Math.max(settings.chaos, cfg.slam_force ?? 2.5);
    if (typeof presetName !== "undefined") presetName.textContent = "MODE: CHAOS";
  } else {
    Object.assign(settings, presets.energy);
    if (typeof presetName !== "undefined") presetName.textContent = "MODE: energy";
  }

  sync();
}

setInterval(applyChaosContract, 30000);
window.addEventListener("focus", applyChaosContract);
document.addEventListener("visibilitychange", applyChaosContract);
'''

s += "\n" + inject + "\napplyChaosContract();\n"
p.write_text(s)
PY

  log "PASS patched wl-matrix main.js"
}

patch_spin_city_rings() {
  local f="$APPS/wl-spin-city/src/matrix/rings.js"
  [[ -f "$f" ]] || { log "WARN missing $f"; return; }

  if grep -q "WL_CHAOS_DROP_IN_SPIN_RINGS" "$f"; then
    log "PASS wl-spin-city rings already patched"
    return
  fi

  backup "$f"

  python3 - "$f" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

s = s.replace(
  "export class Rings {",
  r'''
// WL_CHAOS_DROP_IN_SPIN_RINGS
async function wlLoadChaosContract() {
  try {
    const response = await fetch("file:///Users/wonderland/Wonderland/vault/chaos/visual-chaos-contract.json?t=" + Date.now(), { cache: "no-store" });
    return await response.json();
  } catch {
    return null;
  }
}

export class Rings {'''
)

s = s.replace(
  "this.items = this.seed();",
  "this.chaos = null;\n    this.items = this.seed();\n    this.reloadChaos();",
  1
)

s = s.replace(
  "this.items = this.seed();",
  "this.items = this.seed();\n    this.reloadChaos();",
  1
)

insert = r'''
  async reloadChaos() {
    const contract = await wlLoadChaosContract();
    this.chaos = contract?.chaos_active ? contract?.apps?.["wl-spin-city"] : null;
    this.items = this.seed();
  }
'''

s = s.replace("  seed() {", insert + "\n  seed() {")

s = s.replace(
  "return [",
  r'''
    const chaos = this.chaos;
    const ringCount = chaos?.rings ?? 5;
    const speedBoost = chaos?.rotation_speed ?? 1.0;
    const jitterBoost = chaos?.jitter ?? 0.35;

    const baseRings = [''',
  1
)

s = s.replace(
  "    ].map((r, i) => ({",
  r'''    ];

    return baseRings.slice(0, ringCount).map((r, i) => ({
''',
  1
)

s = s.replace(
  "speed: r.speed,",
  "speed: r.speed * speedBoost,"
)

s = s.replace(
  "wobble: 0.002 + i * 0.0015,",
  "wobble: (0.002 + i * 0.0015) * (1 + jitterBoost),"
)

s = s.replace(
  "speed: r.speed * (1.5 + Math.random() * 0.7),",
  "speed: r.speed * speedBoost * (1.5 + Math.random() * 0.7),"
)

p.write_text(s)
PY

  log "PASS patched wl-spin-city rings.js"
}

patch_spin_city_engine() {
  local f="$APPS/wl-spin-city/src/matrix/spin-city-engine.js"
  [[ -f "$f" ]] || { log "WARN missing $f"; return; }

  if grep -q "WL_CHAOS_DROP_IN_SPIN_ENGINE" "$f"; then
    log "PASS wl-spin-city engine already patched"
    return
  fi

  backup "$f"

  python3 - "$f" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

s = s.replace(
  "export class SpinCityEngine {",
  r'''
// WL_CHAOS_DROP_IN_SPIN_ENGINE
export class SpinCityEngine {'''
)

s = s.replace(
  "this.nextCapture = 0;",
  "this.nextCapture = 0;\n    this.nextChaosReload = 0;",
  1
)

s = s.replace(
  "this.rings.update(dt, this.trajectory);",
  r'''if (time > this.nextChaosReload && this.rings.reloadChaos) {
      this.rings.reloadChaos();
      this.nextChaosReload = time + 30000;
    }

    this.rings.update(dt, this.trajectory);''',
  1
)

p.write_text(s)
PY

  log "PASS patched wl-spin-city spin-city-engine.js"
}

log "=== JS Chaos Contract Auto Drop-In $STAMP ==="
patch_agitate
patch_matrix
patch_spin_city_rings
patch_spin_city_engine
log ""
log "Report: $REPORT"
log "Backups: *.backup.$STAMP beside changed files"
