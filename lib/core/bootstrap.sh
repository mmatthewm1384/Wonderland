#!/usr/bin/env bash
set -euo pipefail

wl_find_root() {
  local start="${1:-$PWD}"

  if command -v git >/dev/null 2>&1; then
    git -C "$start" rev-parse --show-toplevel 2>/dev/null && return 0
  fi

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  printf '%s\n' "$script_dir"
}

export WL_ROOT="${WL_ROOT:-$(wl_find_root)}"
export WONDERLAND_BUILD_ROOT="${WONDERLAND_BUILD_ROOT:-$HOME/Wonderland-Builds}"

mkdir -p "$WONDERLAND_BUILD_ROOT"
