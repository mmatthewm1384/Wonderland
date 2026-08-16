#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT"

CONFIG="release"
BUILD_DIR="$ROOT/.build/$CONFIG"
APP="$ROOT/.build/Nexil.app"

swift build -c "$CONFIG"
BIN="$(swift build -c "$CONFIG" --show-bin-path)/Nexil"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Nexil"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"

/usr/bin/codesign --force --deep --sign - "$APP"

printf '%s\n' "$APP"
