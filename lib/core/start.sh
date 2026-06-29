#!/usr/bin/env bash

wl_start_services() {
  if declare -F wl_services_start >/dev/null 2>&1; then
    wl_services_start
  else
    wl_warn "no service start implementation registered"
  fi
}

wl_start_main() {
  wl_boot_environment
  wl_boot_storage
  wl_boot_runtime
  wl_start_services
  wl_write_report "start.json" status "PASS" root "$WL_ROOT"
  wl_pass "platform started"
  wl_result PASS
}
