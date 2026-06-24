#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APP_ROOT="$ROOT/apps/macos/wl-chaos-menubar"
SRC="$APP_ROOT/Sources/wl-chaos-menubar"
MAIN="$SRC/main.swift"
BACKUPS="$APP_ROOT/backups"
WRAP="$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-menubar"
LOG="$ROOT/vault/chaos/menubar.log"
GOV="$ROOT/Wonderland-v4/governance"
WL="$ROOT/bin/wl"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUPS" "$ROOT/vault/chaos" "$GOV" "$ROOT/vault/08-Operations/reports"

cp "$MAIN" "$BACKUPS/main.swift.backup.$STAMP"

python3 - "$MAIN" <<'PY'
from pathlib import Path
import sys
import re

p = Path(sys.argv[1])
s = p.read_text()

# Replace glyph renderer with cleaner orbit beacon.
start = s.find("func wlGlyph(_ color: NSColor) -> NSImage {")
end = s.find("func wlSetGlyph", start)

if start != -1 and end != -1:
    new = r'''func wlGlyph(_ color: NSColor) -> NSImage {
    let size = NSSize(width: 20, height: 20)
    let image = NSImage(size: size)

    image.lockFocus()

    NSColor.clear.setFill()
    NSRect(origin: .zero, size: size).fill()

    let center = NSPoint(x: size.width / 2, y: size.height / 2)

    color.setStroke()
    color.setFill()

    let outer = NSBezierPath()
    outer.lineWidth = 1.7
    outer.appendOval(
        in: NSRect(
            x: center.x - 7.0,
            y: center.y - 7.0,
            width: 14.0,
            height: 14.0
        )
    )
    outer.stroke()

    let inner = NSBezierPath()
    inner.lineWidth = 1.2
    inner.appendOval(
        in: NSRect(
            x: center.x - 4.0,
            y: center.y - 4.0,
            width: 8.0,
            height: 8.0
        )
    )
    inner.stroke()

    let node = NSBezierPath()
    node.appendOval(
        in: NSRect(
            x: center.x - 1.7,
            y: center.y - 1.7,
            width: 3.4,
            height: 3.4
        )
    )
    node.fill()

    // Broken orbit notch.
    NSColor.clear.setStroke()
    let cut = NSBezierPath()
    cut.lineWidth = 3.2
    cut.move(to: NSPoint(x: center.x + 3.0, y: center.y + 7.4))
    cut.line(to: NSPoint(x: center.x + 8.0, y: center.y + 2.8))
    cut.stroke()

    image.unlockFocus()
    image.isTemplate = false

    return image
}

'''
    s = s[:start] + new + s[end:]

# Replace wlSetGlyph with icon-only behavior.
start = s.find("func wlSetGlyph(")
end = s.find("func chaosActive()", start)
if start != -1 and end != -1:
    new = r'''func wlSetGlyph(_ button: NSStatusBarButton?, color: NSColor, title: String) {
    button?.image = wlGlyph(color)
    button?.imagePosition = .imageOnly
    button?.title = ""
    button?.attributedTitle = NSAttributedString(string: "")
}

'''
    s = s[:start] + new + s[end:]

p.write_text(s)
PY

mv "$SRC"/*.backup.* "$BACKUPS"/ 2>/dev/null || true

cd "$APP_ROOT"
swift build -c release
cp "$APP_ROOT/.build/release/wl-chaos-menubar" "$APP_ROOT/build/wl-chaos-menubar"

cat > "$GOV/verify-chaos-menubar.py" <<'PY'
#!/usr/bin/env python3
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

root = Path.home() / "Wonderland"
report = root / "vault/08-Operations/reports/chaos-menubar-report.json"
binary = root / "apps/macos/wl-chaos-menubar/build/wl-chaos-menubar"
contract = root / "vault/chaos/visual-chaos-contract.json"
runs = root / "vault/ephemeral-runs.log"
watchdog = root / "Wonderland-v4/ephemeral/bin/wl-chaos-watchdog"

checks = []

def add(name, ok, detail=""):
    checks.append({"name": name, "passed": bool(ok), "detail": str(detail)})

def cmd_ok(args):
    try:
        subprocess.check_output(args, stderr=subprocess.STDOUT, timeout=5)
        return True
    except Exception:
        return False

try:
    ps = subprocess.check_output(["pgrep", "-fl", "wl-chaos-menubar"], text=True)
    running = "wl-chaos-menubar" in ps
except Exception:
    ps = ""
    running = False

add("process", running, ps.strip())
add("binary", binary.exists(), binary)
add("contract-readable", contract.exists() and contract.is_file(), contract)
add("activity-log-readable", runs.exists() and runs.is_file(), runs)
add("watchdog-reachable", watchdog.exists() and cmd_ok([str(watchdog), "countdown"]), watchdog)

source = root / "apps/macos/wl-chaos-menubar/Sources/wl-chaos-menubar/main.swift"
src = source.read_text(errors="ignore") if source.exists() else ""
add("glyph-icon-only", ".imageOnly" in src and "wlGlyph" in src, source)
add("live-countdown", "countdownDisplay" in src and "updateCountdown" in src, source)
add("contract-preview", "contractPreview" in src, source)
add("recent-activity", "recentActivity" in src, source)

result = all(c["passed"] for c in checks)
payload = {
    "timestamp": datetime.now(timezone.utc).isoformat(),
    "result": "PASS" if result else "FAIL",
    "checks": checks,
}

report.parent.mkdir(parents=True, exist_ok=True)
report.write_text(json.dumps(payload, indent=2, sort_keys=True))

for c in checks:
    print(("PASS" if c["passed"] else "FAIL"), c["name"])
print()
print("RESULT", "PASS" if result else "FAIL")
print("Report:", report)
PY

chmod +x "$GOV/verify-chaos-menubar.py"

# Try to add governance route only if wl is readable and not broken.
if [[ -f "$WL" ]]; then
  cp "$WL" "$WL.backup.$STAMP"
  if bash -n "$WL" 2>/dev/null && ! grep -q "verify-chaos-menubar.py" "$WL"; then
    python3 - "$WL" <<'PY' || true
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

needle = '''verify-chaos)
        shift
        exec python3 "$ROOT/Wonderland-v4/governance/verify-chaos.py" "$@"
        ;;'''

insert = needle + '''

      verify-chaos-menubar)
        shift
        exec python3 "$ROOT/Wonderland-v4/governance/verify-chaos-menubar.py" "$@"
        ;;'''

if needle in s:
    s = s.replace(needle, insert, 1)
    p.write_text(s)
PY
  fi
fi

pkill -f wl-chaos-menubar 2>/dev/null || true
nohup "$WRAP" > "$LOG" 2>&1 &

echo "PASS menu glyph cleanup + certification installed"
echo "Backup: $BACKUPS/main.swift.backup.$STAMP"
echo "Verify:"
echo "  python3 $GOV/verify-chaos-menubar.py"
echo "  wl governance verify-chaos-menubar  # if bin/wl route is healthy"
