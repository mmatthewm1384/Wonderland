#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APP_ROOT="$ROOT/apps/macos/wl-chaos-menubar"
SRC="$APP_ROOT/Sources/wl-chaos-menubar"
MAIN="$SRC/main.swift"
BACKUPS="$APP_ROOT/backups"
WRAP="$ROOT/Wonderland-v4/ephemeral/bin/wl-chaos-menubar"
LOG="$ROOT/vault/chaos/menubar.log"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUPS" "$ROOT/vault/chaos"

cp "$MAIN" "$BACKUPS/main.swift.backup.$STAMP"

python3 - "$MAIN" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

if "WL_ACTIVITY_CONTRACT_PREVIEW" not in s:
    s = s.replace(
        'var recentActivity: [String] = []',
        '''var recentActivity: [String] = []
    var lastActivityDisplay = "Unknown"
    var lastCheckInDisplay = "Unknown"
    var contractPreview: [String] = []'''
    )

    s = s.replace(
        'func updateRecentActivity() {',
        '''// WL_ACTIVITY_CONTRACT_PREVIEW
    func relativeAge(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date = formatter.date(from: iso)

        if date == nil {
            let fallback = ISO8601DateFormatter()
            fallback.formatOptions = [.withInternetDateTime]
            date = fallback.date(from: iso)
        }

        guard let d = date else {
            return "unknown"
        }

        let seconds = max(0, Int(Date().timeIntervalSince(d)))

        if seconds < 60 {
            return "\\(seconds)s ago"
        }

        let minutes = seconds / 60
        if minutes < 60 {
            return "\\(minutes)m ago"
        }

        let hours = minutes / 60
        let rem = minutes % 60
        return "\\(hours)h \\(rem)m ago"
    }

    func updateActivityAges() {
        let raw = readFile(runsLogPath)
        let lines = raw.split(separator: "\\n").reversed()

        var lastAny: String? = nil
        var lastCheck: String? = nil

        for line in lines {
            guard
                let data = String(line).data(using: .utf8),
                let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                continue
            }

            let ts = (obj["recorded_at"] as? String)
                ?? (obj["valid_at"] as? String)
                ?? (obj["timestamp"] as? String)

            let event = obj["event"] as? String

            if lastAny == nil, let ts {
                lastAny = ts
            }

            if lastCheck == nil, event == "operator_checkin", let ts {
                lastCheck = ts
            }

            if lastAny != nil && lastCheck != nil {
                break
            }
        }

        lastActivityDisplay = lastAny.map(relativeAge) ?? "Unknown"
        lastCheckInDisplay = lastCheck.map(relativeAge) ?? "Unknown"
    }

    func updateContractPreview() {
        let raw = readFile(contractPath)

        guard
            let data = raw.data(using: .utf8),
            let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            contractPreview = ["Contract unavailable"]
            return
        }

        let active = (obj["chaos_active"] as? Bool) ?? false
        var lines: [String] = []

        lines.append("chaos_active: \\(active ? "true" : "false")")

        if
            let apps = obj["apps"] as? [String: Any],
            let spin = apps["wl-spin-city"] as? [String: Any],
            let agitate = apps["wl-agitate"] as? [String: Any],
            let matrix = apps["wl-matrix"] as? [String: Any]
        {
            let rings = spin["rings"] ?? "?"
            let rotation = spin["rotation_speed"] ?? "?"
            let intensity = agitate["intensity"] ?? "?"
            let particles = matrix["particles"] ?? "?"
            let living = matrix["living_ratio"] ?? "?"

            lines.append("rings: \\(rings)")
            lines.append("rotation: \\(rotation)")
            lines.append("intensity: \\(intensity)")
            lines.append("particles: \\(particles)")
            lines.append("living_ratio: \\(living)")
        }

        contractPreview = lines
    }

    func updateRecentActivity() {'''
    )

    s = s.replace(
        '''updateRecentActivity()
        buildMenu()''',
        '''updateActivityAges()
        updateContractPreview()
        updateRecentActivity()
        buildMenu()'''
    )

    s = s.replace(
        '''menu.addItem(disabled("Escalation In"))
        menu.addItem(coloredDisabled(countdownDisplay, color: countdownColor()))''',
        '''menu.addItem(disabled("Escalation In"))
        menu.addItem(coloredDisabled(countdownDisplay, color: countdownColor()))

        menu.addItem(.separator())
        menu.addItem(disabled("Last Activity"))
        menu.addItem(disabled(lastActivityDisplay))
        menu.addItem(disabled("Last Check-In"))
        menu.addItem(disabled(lastCheckInDisplay))

        menu.addItem(.separator())
        menu.addItem(disabled("Contract"))
        for line in contractPreview.prefix(6) {
            menu.addItem(disabled(line))
        }'''
    )

p.write_text(s)
PY

mv "$SRC"/*.backup.* "$BACKUPS"/ 2>/dev/null || true

cd "$APP_ROOT"
swift build -c release

cp "$APP_ROOT/.build/release/wl-chaos-menubar" "$APP_ROOT/build/wl-chaos-menubar"

pkill -f wl-chaos-menubar 2>/dev/null || true
nohup "$WRAP" > "$LOG" 2>&1 &

echo "PASS activity + contract preview installed"
echo "Backup: $BACKUPS/main.swift.backup.$STAMP"
echo "Log: $LOG"
