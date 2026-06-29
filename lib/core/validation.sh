#!/usr/bin/env bash

wl_validate_file() {
  local path="$1"
  [ -f "$path" ] || wl_die "$WL_ERR_VALIDATION" "missing file: $path"
  wl_pass "file exists: $path"
}

wl_validate_json() {
  local path="$1"
  wl_json_require
  jq empty "$path" >/dev/null || wl_die "$WL_ERR_VALIDATION" "invalid json: $path"
  wl_pass "valid json: $path"
}

wl_validate_runtime() {
  wl_validate_json "$WL_RUNTIME_DIR/context.json"
  wl_validate_json "$WL_RUNTIME_DIR/state.json"
  wl_validate_json "$WL_RUNTIME_DIR/health.json"
  wl_validate_json "$WL_RUNTIME_DIR/capabilities.json"
}
