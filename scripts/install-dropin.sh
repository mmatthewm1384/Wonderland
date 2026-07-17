#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

mkdir -p "$HOME/bin"

ln -sf \
    "$ROOT/scripts/wl" \
    "$HOME/bin/wl"

echo "Installed:"
echo "  $HOME/bin/wl"
