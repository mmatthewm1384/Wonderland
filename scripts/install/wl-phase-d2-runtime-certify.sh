#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
REPORT="$ROOT/vault/08-Operations/reports/phase-d2-runtime-certification.json"
TXT="$ROOT/vault/08-Operations/reports/phase-d2-runtime-certification.txt"

mkdir -p "$(dirname "$REPORT")"

python3 - "$ROOT" "$REPORT" "$TXT" <<'PY'
import json
import subprocess
from pathlib import Path
from datetime import datetime, timezone

root = Path(__import__("sys").argv[1])
report = Path(__import__("sys").argv[2])
txt = Path(__import__("sys").argv[3])

apps = {
    "wl-spin-city": {
        "tauri": root / "apps/tauri/wl-spin-city",
        "macos_app": root / "apps/macos/Spin City Wave.app",
        "js_markers": ["wlNativeReadChaosContract", "WL_PHASE_D1_SPIN_CITY_LIVE_APPLY"],
    },
    "wl-agitate": {
        "tauri": root / "apps/tauri/wl-agitate",
        "macos_app": root / "apps/macos/Agitate Waves.app",
        "js_markers": ["wlNativeReadChaosContract", "WL_PHASE_D1_AGITATE_LIVE_APPLY"],
    },
    "wl-matrix": {
        "tauri": root / "apps/tauri/wl-matrix",
        "macos_app": root / "apps/macos/Matrix Atom Destroyer.app",
        "js_markers": ["wlNativeReadChaosContract", "WL_PHASE_D1_MATRIX_LIVE_APPLY"],
    },
}

checks = []

def add(name, ok, detail=""):
    checks.append({"name": name, "passed": bool(ok), "detail": str(detail)})

def read(path):
    try:
        return path.read_text(errors="ignore")
    except Exception:
        return ""

for name, cfg in apps.items():
    tauri = cfg["tauri"]
    rust_lib = tauri / "src-tauri/src/lib.rs"
    rust_contract = tauri / "src-tauri/src/chaos_contract.rs"
    src = tauri / "src"

    add(f"{name}: rust command file", rust_contract.exists(), rust_contract)
    add(f"{name}: rust invoke handler", "read_chaos_contract" in read(rust_lib), rust_lib)

    js_blob = ""
    if src.exists():
        for f in src.rglob("*.js"):
            js_blob += read(f) + "\n"

    for marker in cfg["js_markers"]:
        add(f"{name}: js marker {marker}", marker in js_blob, marker)

    add(f"{name}: macOS app bundle", cfg["macos_app"].exists(), cfg["macos_app"])

contract = root / "vault/chaos/visual-chaos-contract.json"
add("visual contract exists", contract.exists(), contract)

if contract.exists():
    try:
        data = json.loads(contract.read_text())
        add("visual contract json valid", isinstance(data, dict), contract)
        add("visual contract has chaos_active", "chaos_active" in data, contract)
        add("visual contract has apps", "apps" in data, contract)
    except Exception as e:
        add("visual contract json valid", False, e)

for cmd in ["wl-chaos", "wl-visual-chaos"]:
    path = root / "bin" / cmd
    add(f"{cmd} wrapper", path.exists() and path.stat().st_mode & 0o111, path)

result = all(c["passed"] for c in checks)

payload = {
    "timestamp": datetime.now(timezone.utc).isoformat(),
    "result": "PASS" if result else "FAIL",
    "checks": checks,
}

report.write_text(json.dumps(payload, indent=2, sort_keys=True))

lines = []
for c in checks:
    lines.append(("PASS " if c["passed"] else "FAIL ") + c["name"])
lines.append("")
lines.append("RESULT " + ("PASS" if result else "FAIL"))
lines.append(f"Report: {report}")

txt.write_text("\n".join(lines) + "\n")
print(txt.read_text())
PY
