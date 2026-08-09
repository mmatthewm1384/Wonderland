#!/usr/bin/env bash
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/sparkctl"

sudo ln -sf "$SRC" /usr/local/bin/sparkctl

echo "[PASS] sparkctl installed"
