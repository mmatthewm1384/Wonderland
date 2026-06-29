#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APPS="$ROOT/apps/tauri"
REPORT="$ROOT/vault/08-Operations/reports/phase-d-native-contract-reader.txt"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$(dirname "$REPORT")"
: > "$REPORT"

log(){ echo "$*" | tee -a "$REPORT"; }

patch_app() {
  local app="$1"
  local dir="$APPS/$app"
  local rust="$dir/src-tauri/src"
  local lib="$rust/lib.rs"

  [[ -d "$dir" ]] || { log "WARN missing $dir"; return; }
  [[ -f "$lib" ]] || { log "WARN missing $lib"; return; }

  cp "$lib" "$lib.backup.$STAMP"

  cat > "$rust/chaos_contract.rs" <<'RS'
use std::fs;
use std::path::PathBuf;

#[tauri::command]
pub fn read_chaos_contract() -> Result<String, String> {
    let home = std::env::var("HOME")
        .map_err(|e| format!("HOME unavailable: {e}"))?;

    let path: PathBuf = [
        home.as_str(),
        "Wonderland",
        "vault",
        "chaos",
        "visual-chaos-contract.json",
    ]
    .iter()
    .collect();

    fs::read_to_string(&path)
        .map_err(|e| format!("failed to read {}: {e}", path.display()))
}
RS

  python3 - "$lib" <<'PY'
from pathlib import Path
import sys, re

p = Path(sys.argv[1])
s = p.read_text()

if "mod chaos_contract;" not in s:
    s = "mod chaos_contract;\n" + s

cmd = "chaos_contract::read_chaos_contract"

if cmd not in s:
    m = re.search(r"invoke_handler\s*\(\s*tauri::generate_handler!\s*\\?\[\s*([^\]]*)\]\s*\)", s, re.S)

    if m:
        inside = m.group(1).strip()
        replacement_inside = (inside + ", " + cmd) if inside else cmd
        s = s[:m.start(1)] + replacement_inside + s[m.end(1):]
    else:
        marker = ".run(tauri::generate_context!())"
        if marker in s:
            s = s.replace(
                marker,
                f".invoke_handler(tauri::generate_handler![{cmd}])\n        {marker}",
                1
            )
        else:
            raise SystemExit("Could not find Tauri Builder run marker")

p.write_text(s)
PY

  for js in "$dir/src/main.js" "$dir/src/matrix/rings.js"; do
    [[ -f "$js" ]] || continue
    cp "$js" "$js.backup.$STAMP"

    python3 - "$js" <<'PY'
from pathlib import Path
import sys, re

p = Path(sys.argv[1])
s = p.read_text()

native = r'''
async function wlNativeReadChaosContract() {
  try {
    if (window.__TAURI__?.core?.invoke) {
      return await window.__TAURI__.core.invoke("read_chaos_contract");
    }
  } catch {}

  try {
    const mod = await import("@tauri-apps/api/core");
    return await mod.invoke("read_chaos_contract");
  } catch {}

  return null;
}
'''

if "wlNativeReadChaosContract" not in s:
    s = native + "\n" + s

def replace_loader(name, text):
    pattern = rf"async function {name}\(\) \{{.*?\n\}}"
    repl = rf'''async function {name}() {{
  try {{
    const native = await wlNativeReadChaosContract();
    if (native) return JSON.parse(native);
  }} catch {{}}

  try {{
    const response = await fetch("file:///Users/wonderland/Wonderland/vault/chaos/visual-chaos-contract.json?t=" + Date.now(), {{ cache: "no-store" }});
    return await response.json();
  }} catch {{
    return null;
  }}
}}'''
    return re.sub(pattern, repl, text, count=1, flags=re.S)

s = replace_loader("loadChaosContract", s)
s = replace_loader("wlLoadChaosContract", s)

p.write_text(s)
PY
  done

  log "PASS patched $app"
}

log "=== Phase D Native Contract Reader $STAMP ==="
patch_app wl-spin-city
patch_app wl-agitate
patch_app wl-matrix
log "Report: $REPORT"
