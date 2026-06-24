#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
GOV="$ROOT/Wonderland-v4/governance"
REPORT="$ROOT/vault/08-Operations/reports/runtime-chaos-governance-report.json"

mkdir -p "$GOV" "$(dirname "$REPORT")"

cat > "$GOV/verify-runtime-chaos.py" <<'PY'
#!/usr/bin/env python3
import json
import subprocess
from pathlib import Path
from datetime import datetime, timezone

root = Path.home() / "Wonderland"
checks = []

def add(name, ok, detail=""):
    checks.append({"name": name, "passed": bool(ok), "detail": str(detail)})

def run_ok(cmd):
    try:
        subprocess.check_output(cmd, stderr=subprocess.STDOUT, timeout=20)
        return True
    except Exception as e:
        return False

add("wl-runtime-chaos-doctor", run_ok([str(root / "bin/wl-runtime-chaos-doctor")]))
add("menubar-launchagent", run_ok(["launchctl", "print", f"gui/{__import__('os').getuid()}/com.wonderland.chaos-menubar"]))
add("menubar-process", run_ok(["pgrep", "-f", "wl-chaos-menubar"]))
add("watchdog", run_ok([str(root / "Wonderland-v4/ephemeral/bin/wl-chaos-watchdog"), "status"]))
add("visual-contract", (root / "vault/chaos/visual-chaos-contract.json").exists())
add("runtime-cert-report", (root / "vault/08-Operations/reports/phase-d2-runtime-certification.json").exists())

result = all(c["passed"] for c in checks)

payload = {
    "timestamp": datetime.now(timezone.utc).isoformat(),
    "result": "PASS" if result else "FAIL",
    "checks": checks,
}

report = root / "vault/08-Operations/reports/runtime-chaos-governance-report.json"
report.write_text(json.dumps(payload, indent=2, sort_keys=True))

for c in checks:
    print(("PASS" if c["passed"] else "FAIL"), c["name"])
print()
print("RESULT", "PASS" if result else "FAIL")
print("Report:", report)
PY

chmod +x "$GOV/verify-runtime-chaos.py"

cat > "$ROOT/bin/wl-governance-runtime-chaos" <<'SH2'
#!/usr/bin/env bash
exec "$HOME/Wonderland/Wonderland-v4/governance/verify-runtime-chaos.py" "$@"
SH2

chmod +x "$ROOT/bin/wl-governance-runtime-chaos"

echo "PASS installed runtime chaos governance"
echo "Run:"
echo "  wl-governance-runtime-chaos"
