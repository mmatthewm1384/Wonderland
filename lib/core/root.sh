#!/usr/bin/env bash
set -euo pipefail

wl_find_root() {
  local dir="${1:-$PWD}"

  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.git" && -x "$dir/bin/wl" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  if [[ -d "$HOME/Wonderland/.git" && -x "$HOME/Wonderland/bin/wl" ]]; then
    printf '%s\n' "$HOME/Wonderland"
    return 0
  fi

  return 1
}

wl_require_root() {
  local root
  root="$(wl_find_root "${1:-$PWD}")" || {
    echo "FAIL Wonderland root not found" >&2
    echo "Tried current path and \$HOME/Wonderland" >&2
    return 1
  }

  printf '%s\n' "$root"
}
