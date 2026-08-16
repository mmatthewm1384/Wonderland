#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT"

swift build -c release
BIN="$ROOT/.build/arm64-apple-macosx/release/Nexil"
[ -x "$BIN" ] || BIN="$ROOT/.build/release/Nexil"
APP="$ROOT/build/Nexil.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Nexil"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleDisplayName</key><string>Nexil</string>
<key>CFBundleExecutable</key><string>Nexil</string>
<key>CFBundleIdentifier</key><string>com.wonderland.nexil</string>
<key>CFBundleName</key><string>Nexil</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.0.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSUIElement</key><true/>
<key>LSMinimumSystemVersion</key><string>14.0</string>
</dict></plist>
PLIST
printf 'Built %s\n' "$APP"
