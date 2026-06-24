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

if "import UserNotifications" not in s:
    s = s.replace("import Foundation", "import Foundation\nimport UserNotifications")

if "WL_COUNTDOWN_NOTIFICATIONS" not in s:
    s = s.replace(
        'var contractPreview: [String] = []',
        '''var contractPreview: [String] = []
    var sentCountdownAlerts: Set<String> = []'''
    )

    s = s.replace(
        'func updateCountdown() {',
        '''// WL_COUNTDOWN_NOTIFICATIONS
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func notify(_ title: String, _ body: String, id: String) {
        if sentCountdownAlerts.contains(id) {
            return
        }

        sentCountdownAlerts.insert(id)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "wonderland-chaos-\\(id)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func maybeNotifyCountdown() {
        guard let h = countdownHours else {
            return
        }

        if h <= 0.083 {
            notify("Wonderland Chaos", "Escalation in 5 minutes", id: "5m")
        } else if h <= 0.25 {
            notify("Wonderland Chaos", "Escalation in 15 minutes", id: "15m")
        } else if h <= 1.0 {
            notify("Wonderland Chaos", "Escalation in 1 hour", id: "1h")
        } else if h <= 2.0 {
            notify("Wonderland Chaos", "Escalation in 2 hours", id: "2h")
        }

        if h > 2.1 {
            sentCountdownAlerts.removeAll()
        }
    }

    func updateCountdown() {'''
    )

    s = s.replace(
        '''            countdownDisplay = formatCountdown(raw)
        } else {''',
        '''            countdownDisplay = formatCountdown(raw)
            maybeNotifyCountdown()
        } else {'''
    )

    s = s.replace(
        'updateCountdown()\n        refresh()',
        'requestNotificationPermission()\n        updateCountdown()\n        refresh()',
        1
    )

p.write_text(s)
PY

mv "$SRC"/*.backup.* "$BACKUPS"/ 2>/dev/null || true

cd "$APP_ROOT"
swift build -c release

cp "$APP_ROOT/.build/release/wl-chaos-menubar" "$APP_ROOT/build/wl-chaos-menubar"

pkill -f wl-chaos-menubar 2>/dev/null || true
nohup "$WRAP" > "$LOG" 2>&1 &

echo "PASS countdown notifications installed"
echo "Backup: $BACKUPS/main.swift.backup.$STAMP"
