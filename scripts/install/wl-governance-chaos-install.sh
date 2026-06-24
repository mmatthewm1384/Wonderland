#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
GOV="$ROOT/Wonderland-v4/governance"
REPORTS="$ROOT/vault/08-Operations/reports"

mkdir -p "$GOV" "$REPORTS"

cat > "$GOV/verify-chaos.py" <<'PY'
#!/usr/bin/env python3

import json
import shutil
import subprocess
from pathlib import Path
from datetime import datetime, timezone

ROOT = Path.home() / "Wonderland"

CHAOS = ROOT / "vault" / "chaos"
REPORT = ROOT / "vault" / "08-Operations" / "reports" / "chaos-governance-report.json"

CHECKS = []

def add(name, passed, detail=""):
    CHECKS.append({
        "name": name,
        "passed": passed,
        "detail": detail
    })

def exists(path):
    return Path(path).exists()

# launchd
plist = Path.home() / "Library" / "LaunchAgents" / "com.wonderland.chaos-watchdog.plist"
add(
    "launchd",
    plist.exists(),
    str(plist)
)

# watchdog
pid = CHAOS / "chaos-watchdog.pid"

running = False

if pid.exists():
    try:
        p = int(pid.read_text().strip())
        subprocess.check_output(["ps", "-p", str(p)])
        running = True
    except Exception:
        pass

add(
    "watchdog",
    running,
    str(pid)
)

# aether
aether = CHAOS / "chaos-aether.json"

add(
    "aether",
    aether.exists(),
    str(aether)
)

# visual contract
contract = CHAOS / "visual-chaos-contract.json"

add(
    "visual-contract",
    contract.exists(),
    str(contract)
)

# panic
panic = ROOT / "Wonderland-v4" / "ephemeral" / "bin" / "wl-chaos-panic"

add(
    "panic",
    panic.exists(),
    str(panic)
)

# skhd config
skhd = Path.home() / ".skhdrc"

add(
    "skhd",
    skhd.exists(),
    str(skhd)
)

# audit log
audit = ROOT / "vault" / "ephemeral-runs.log"

audit_ok = audit.exists() and audit.is_file()

add(
    "audit",
    audit_ok,
    str(audit)
)

result = all(c["passed"] for c in CHECKS)

payload = {
    "timestamp": datetime.now(timezone.utc).isoformat(),
    "result": "PASS" if result else "FAIL",
    "checks": CHECKS
}

REPORT.parent.mkdir(parents=True, exist_ok=True)
REPORT.write_text(json.dumps(payload, indent=2))

for c in CHECKS:
    print(
        f'{"PASS" if c["passed"] else "FAIL"} {c["name"]}'
    )

print()
print("RESULT", "PASS" if result else "FAIL")
print()
print("Report:", REPORT)
PY

chmod +x "$GOV/verify-chaos.py"

echo
echo "Installed:"
echo "  $GOV/verify-chaos.py"
