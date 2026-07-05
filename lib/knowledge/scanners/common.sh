#!/usr/bin/env bash
set -euo pipefail

wks_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

wks_generated_dir() {
  local root
  root="$(wks_root)"
  mkdir -p "$root/knowledge/generated"
  printf '%s\n' "$root/knowledge/generated"
}

wks_count_files() {
  local path="$1"
  local pattern="${2:-*}"
  if [ -d "$path" ]; then
    find "$path" -type f -name "$pattern" 2>/dev/null | wc -l | tr -d ' '
  else
    printf '0\n'
  fi
}

wks_count_dirs_named() {
  local root="$1"
  local name="$2"
  if [ -d "$root" ]; then
    find "$root" -type d -name "$name" 2>/dev/null | wc -l | tr -d ' '
  else
    printf '0\n'
  fi
}
