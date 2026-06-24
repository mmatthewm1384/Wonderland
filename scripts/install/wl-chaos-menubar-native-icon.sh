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

if "WL_NATIVE_MENU_GLYPH" not in s:
    s = s.replace(
        '''func wlStatusTitle(_ text: String, color: NSColor) -> NSAttributedString {
    return NSAttributedString(
        string: text,
        attributes: [
            .foregroundColor: color,
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
        ]
    )
}''',
        '''// WL_NATIVE_MENU_GLYPH
func wlStatusTitle(_ text: String, color: NSColor) -> NSAttributedString {
    return NSAttributedString(
        string: text,
        attributes: [
            .foregroundColor: color,
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
        ]
    )
}

func wlGlyph(_ color: NSColor) -> NSImage {
    let size = NSSize(width: 22, height: 18)
    let image = NSImage(size: size)

    image.lockFocus()

    NSColor.clear.setFill()
    NSRect(origin: .zero, size: size).fill()

    let center = NSPoint(x: size.width / 2, y: size.height / 2)

    color.setStroke()

    let outer = NSBezierPath()
    outer.lineWidth = 1.8
    outer.appendOval(
        in: NSRect(
            x: center.x - 6.5,
            y: center.y - 6.5,
            width: 13,
            height: 13
        )
    )
    outer.stroke()

    let inner = NSBezierPath()
    inner.lineWidth = 1.2
    inner.appendOval(
        in: NSRect(
            x: center.x - 2.4,
            y: center.y - 2.4,
            width: 4.8,
            height: 4.8
        )
    )
    inner.stroke()

    let slash = NSBezierPath()
    slash.lineWidth = 1.4
    slash.move(to: NSPoint(x: center.x - 8, y: center.y - 7))
    slash.line(to: NSPoint(x: center.x + 8, y: center.y + 7))
    slash.stroke()

    image.unlockFocus()
    image.isTemplate = false

    return image
}

func wlSetGlyph(_ button: NSStatusBarButton?, color: NSColor, title: String) {
    button?.image = wlGlyph(color)
    button?.imagePosition = .imageLeft
    button?.title = title
    button?.attributedTitle = wlStatusTitle(title, color: color)
}'''
    )

    s = s.replace(
        'item.button?.attributedTitle = wlStatusTitle("◉ WL", color: wlCyan)',
        'wlSetGlyph(item.button, color: wlCyan, title: "WL")'
    )

    s = s.replace(
        'item.button?.attributedTitle = wlStatusTitle("◉ FAIL", color: wlRed)',
        'wlSetGlyph(item.button, color: wlRed, title: "FAIL")'
    )

    s = s.replace(
        'item.button?.attributedTitle = wlStatusTitle("◉ SOON", color: wlGreen)',
        'wlSetGlyph(item.button, color: wlGreen, title: "SOON")'
    )

    s = s.replace(
        'item.button?.attributedTitle = wlStatusTitle("◉ CHAOS", color: wlPurple)',
        'wlSetGlyph(item.button, color: wlPurple, title: "CHAOS")'
    )

    s = s.replace(
        'item.button?.attributedTitle = wlStatusTitle("◉ WL", color: wlCyan)',
        'wlSetGlyph(item.button, color: wlCyan, title: "WL")'
    )

p.write_text(s)
PY

mv "$SRC"/*.backup.* "$BACKUPS"/ 2>/dev/null || true

cd "$APP_ROOT"
swift build -c release

cp "$APP_ROOT/.build/release/wl-chaos-menubar" "$APP_ROOT/build/wl-chaos-menubar"

pkill -f wl-chaos-menubar 2>/dev/null || true
nohup "$WRAP" > "$LOG" 2>&1 &

echo "PASS native Wonderland menu glyph installed"
echo "Backup: $BACKUPS/main.swift.backup.$STAMP"
echo "Log: $LOG"
