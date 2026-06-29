#!/usr/bin/env bash

wl_release_dir() {
  local dir="$WL_ROOT/vault/08-Operations/releases"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}

wl_release_manifest_path() {
  local ts="$1"
  printf '%s/release-%s.json\n' "$(wl_release_dir)" "$ts"
}

wl_release_history_file() {
  printf '%s/history.jsonl\n' "$(wl_release_dir)"
}
