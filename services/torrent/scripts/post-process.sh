#!/usr/bin/env bash
set -euo pipefail

TARGET="${TR_TORRENT_DIR}/${TR_TORRENT_NAME}"
QUARANTINE="/quarantine"

echo "wl-torrent post-process: $TARGET"

if [ ! -e "$TARGET" ]; then
  echo "missing target"
  exit 1
fi

BAD="$(find "$TARGET" -type f \( \
  -iname "*.exe" -o \
  -iname "*.bat" -o \
  -iname "*.cmd" -o \
  -iname "*.scr" -o \
  -iname "*.lnk" -o \
  -iname "*.sh" -o \
  -iname "*.app" \
\) 2>/dev/null || true)"

if [ -n "$BAD" ]; then
  echo "unsafe payload detected"
  echo "$BAD"
  mkdir -p "$QUARANTINE"
  mv "$TARGET" "$QUARANTINE/"
  exit 1
fi

find "$TARGET" -type f -exec shasum -a 256 {} \; > "${TARGET}.sha256"
echo "verified: $TARGET"
