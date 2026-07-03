#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/lib/core/bootstrap.sh"

VENV="$WL_ROOT/.venv"
PYTHON="$VENV/bin/python"

export WONDERLAND_BUILD_ROOT="${WONDERLAND_BUILD_ROOT:-$HOME/Wonderland-Builds}"
export WL_BUILDER_MANAGED="1"

mkdir -p "$WONDERLAND_BUILD_ROOT"

if [ ! -x "$PYTHON" ]; then
  echo "wl builder: creating Python environment: $VENV" >&2
  python3 -m venv "$VENV"
fi

"$PYTHON" -m pip install --upgrade pip setuptools wheel >/dev/null
"$PYTHON" -m pip install -e "$WL_ROOT/builder" >/dev/null

exec env \
  WL_BUILDER_MANAGED="$WL_BUILDER_MANAGED" \
  WONDERLAND_BUILD_ROOT="$WONDERLAND_BUILD_ROOT" \
  "$PYTHON" -m wlbuilder "$@"
