#!/usr/bin/env bash

wl_boot_environment() {
  [ -d "$WL_ROOT/bin" ] || wl_die "$WL_ERR_CONFIG" "missing bin directory"
  [ -d "$WL_ROOT/lib" ] || wl_die "$WL_ERR_CONFIG" "missing lib directory"
  wl_pass "environment verified"
}

wl_boot_storage() {
  mkdir -p "$WL_RUNTIME_DIR" "$WL_REPORTS_DIR" "$WL_STATE_DIR" "$WL_LOGS_DIR"
  wl_pass "storage verified"
}

wl_boot_runtime() {
  wl_runtime_refresh
  wl_pass "runtime online"
}

wl_boot_report() {
  wl_write_report "boot.json" status "PASS" root "$WL_ROOT"
}

wl_boot() {
  wl_boot_environment
  wl_boot_storage
  wl_boot_runtime
  wl_boot_report
  wl_result PASS
}
