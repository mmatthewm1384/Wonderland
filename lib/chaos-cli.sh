#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_HOME:-$HOME/Wonderland}"
exec "$ROOT/bin/wl-chaos" "$@"
