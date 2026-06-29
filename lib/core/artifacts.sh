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

wl_sha256_file() {
  local path="$1"

  [ -f "$path" ] || wl_die "$WL_ERR_VALIDATION" "missing digest file: $path"

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$path" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$path" | awk '{print $1}'
  else
    wl_die "$WL_ERR_CONFIG" "missing SHA-256 tool: shasum or sha256sum required"
  fi
}
