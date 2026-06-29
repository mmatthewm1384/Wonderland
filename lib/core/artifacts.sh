#!/usr/bin/env bash

wl_timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

wl_artifact_dir() {
  local name="$1"
  local dir="$WL_ROOT/vault/08-Operations/$name"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}

wl_write_report() {
  local name="$1"
  local path="$WL_REPORTS_DIR/$name"
  shift
  wl_json_write_object "$path" generated_at "$(wl_timestamp)" "$@"
  wl_report "$path"
}
