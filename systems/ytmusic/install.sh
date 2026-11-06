#!/bin/bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/Wonderland/wonderland}"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$WL_ROOT/systems/ytmusic"

if [[ ! -d "$WL_ROOT" ]]; then
  echo "FAIL: WL_ROOT does not exist: $WL_ROOT" >&2
  exit 1
fi

if [[ -e "$TARGET" ]]; then
  echo "REFUSING: target already exists: $TARGET" >&2
  echo "Inspect and back up the existing target before installing." >&2
  exit 2
fi

mkdir -p "$(dirname "$TARGET")"
ditto "$SOURCE_DIR" "$TARGET"
chmod +x "$TARGET/bin/ytmusic" "$TARGET/install.sh"

echo "Installed: $TARGET"
echo "Add this to your shell PATH:"
echo "  export PATH=\"$TARGET/bin:\$PATH\""
echo "Then run: ytmusic status"
