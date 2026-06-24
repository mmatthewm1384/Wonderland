#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APPS="$ROOT/apps/tauri"
REPORT="$ROOT/vault/08-Operations/reports/phase-d1-live-runtime-apply.txt"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$(dirname "$REPORT")"
: > "$REPORT"

log(){ echo "$*" | tee -a "$REPORT"; }

patch_agitate() {
  local f="$APPS/wl-agitate/src/main.js"
  [[ -f "$f" ]] || { log "WARN missing $f"; return; }

  if grep -q "WL_PHASE_D1_AGITATE_LIVE_APPLY" "$f"; then
    log "PASS wl-agitate already patched"
    return
  fi

  cp "$f" "$f.backup.$STAMP"

  cat >> "$f" <<'JS'

// WL_PHASE_D1_AGITATE_LIVE_APPLY
let wlAgitateLastContract = "";

async function wlAgitateLiveApply() {
  try {
    const native = await wlNativeReadChaosContract();
    if (!native || native === wlAgitateLastContract) return;

    wlAgitateLastContract = native;

    const contract = JSON.parse(native);
    const cfg = contract?.chaos_active ? contract?.apps?.["wl-agitate"] : null;

    if (cfg) {
      settings.density = Math.max(120, Math.round((cfg.intensity ?? 2.0) * 60));
      settings.speed = 0.55;
      settings.glow = 1.25;
      settings.tension = 2.2;
      if (typeof presetName !== "undefined") presetName.textContent = "MODE: CHAOS LIVE";
    } else {
      Object.assign(settings, presets.ambient);
      if (typeof presetName !== "undefined") presetName.textContent = "MODE: ambient";
    }

    sync();
  } catch (error) {
    console.warn("wl-agitate live chaos apply failed", error);
  }
}

setInterval(wlAgitateLiveApply, 5000);
window.addEventListener("focus", wlAgitateLiveApply);
document.addEventListener("visibilitychange", wlAgitateLiveApply);
wlAgitateLiveApply();
JS

  log "PASS patched wl-agitate live apply"
}

patch_matrix() {
  local f="$APPS/wl-matrix/src/main.js"
  [[ -f "$f" ]] || { log "WARN missing $f"; return; }

  if grep -q "WL_PHASE_D1_MATRIX_LIVE_APPLY" "$f"; then
    log "PASS wl-matrix already patched"
    return
  fi

  cp "$f" "$f.backup.$STAMP"

  cat >> "$f" <<'JS'

// WL_PHASE_D1_MATRIX_LIVE_APPLY
let wlMatrixLastContract = "";

async function wlMatrixLiveApply() {
  try {
    const native = await wlNativeReadChaosContract();
    if (!native || native === wlMatrixLastContract) return;

    wlMatrixLastContract = native;

    const contract = JSON.parse(native);
    const cfg = contract?.chaos_active ? contract?.apps?.["wl-matrix"] : null;

    if (cfg) {
      settings.density = Math.max(220, Math.round((cfg.particles ?? 10000) / 45));
      settings.speed = 0.9;
      settings.glow = 1.4;
      settings.chaos = Math.max(2.5, cfg.slam_force ?? 2.5);
      if (typeof presetName !== "undefined") presetName.textContent = "MODE: CHAOS LIVE";
    } else {
      Object.assign(settings, presets.energy);
      if (typeof presetName !== "undefined") presetName.textContent = "MODE: energy";
    }

    sync();
  } catch (error) {
    console.warn("wl-matrix live chaos apply failed", error);
  }
}

setInterval(wlMatrixLiveApply, 5000);
window.addEventListener("focus", wlMatrixLiveApply);
document.addEventListener("visibilitychange", wlMatrixLiveApply);
wlMatrixLiveApply();
JS

  log "PASS patched wl-matrix live apply"
}

patch_spin_city() {
  local f="$APPS/wl-spin-city/src/matrix/rings.js"
  [[ -f "$f" ]] || { log "WARN missing $f"; return; }

  if grep -q "WL_PHASE_D1_SPIN_CITY_LIVE_APPLY" "$f"; then
    log "PASS wl-spin-city already patched"
    return
  fi

  cp "$f" "$f.backup.$STAMP"

  python3 - "$f" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

# Constructor: ensure baseline contract hash exists.
s = s.replace(
    "this.chaos = null;",
    "this.chaos = null;\n    this.wlLastContract = \"\";",
    1
)

# Replace reloadChaos with change-detecting live version if present.
start = s.find("  async reloadChaos() {")
if start != -1:
    end = s.find("\n  seed() {", start)
    if end != -1:
        replacement = r'''  // WL_PHASE_D1_SPIN_CITY_LIVE_APPLY
  async reloadChaos() {
    const contract = await wlLoadChaosContract();
    const serialized = JSON.stringify(contract ?? {});

    if (serialized === this.wlLastContract) {
      return;
    }

    this.wlLastContract = serialized;
    this.chaos = contract?.chaos_active ? contract?.apps?.["wl-spin-city"] : null;
    this.items = this.seed();
  }
'''
        s = s[:start] + replacement + s[end:]

p.write_text(s)
PY

  log "PASS patched wl-spin-city live apply"
}

log "=== Phase D.1 Live Runtime Apply $STAMP ==="
patch_agitate
patch_matrix
patch_spin_city
log "Report: $REPORT"
