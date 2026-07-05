#!/usr/bin/env bash
set -euo pipefail

wl_root_resolve() {
  local start="${1:-$PWD}"
  local dir="$start"

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

  echo "FAIL Wonderland root not found" >&2
  return 1
}

wl_root_print() {
  wl_root_resolve "${1:-$PWD}"
}
