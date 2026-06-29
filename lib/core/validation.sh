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

wl_validate_command_exists() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || wl_die "$WL_ERR_VALIDATION" "missing command: $cmd"
  wl_pass "command available: $cmd"
}

wl_validate_registry() {
  local registry="$WL_ROOT/config/commands/registry.json"
  wl_validate_json "$registry"
  wl_pass "command registry valid"
}

wl_verify_core() {
  wl_boot_environment
  wl_boot_storage
  wl_runtime_refresh
  wl_validate_runtime
  wl_validate_registry
  wl_release_validate
  wl_write_report "verify.json" status "PASS" root "$WL_ROOT"
  wl_result PASS
}
