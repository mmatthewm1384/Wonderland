#!/usr/bin/env sh
set -eu

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
WL_TOOLS="$WL_ROOT/tools"
WL_BIN="$WL_TOOLS/bin"

mkdir -p "$WL_BIN"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

for cmd in "$SCRIPT_DIR"/bin/wl-*; do
  name="$(basename "$cmd")"
  cp "$cmd" "$WL_BIN/$name"
  chmod +x "$WL_BIN/$name"
done

echo "Installed wl commands to: $WL_BIN"
echo "Add this to your shell profile if needed:"
echo "export PATH=\"$WL_BIN:\$PATH\""
