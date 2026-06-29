#!/usr/bin/env bash

: "${WL_HOME:=$HOME/Wonderland}"
: "${WL_T7_PATH:=/Volumes/T7_Wonderland}"

wl_storage_t7_attached() {
  [[ -d "$WL_T7_PATH" ]]
}

wl_storage_status() {
  wl_section "Wonderland Storage"

  wl_required_path "internal root" "$WL_HOME"
  wl_required_path "internal vault" "$WL_HOME/vault"

  if wl_storage_t7_attached; then
    wl_pass "t7" "connected: $WL_T7_PATH"
    wl_optional_path "t7 mirror" "$WL_T7_PATH/Wonderland"
    wl_optional_path "media" "$WL_T7_PATH/media"
  else
    wl_warn "t7" "detached; internal/light mode active"
    wl_warn "t7 mirror" "unavailable"
    wl_warn "media" "unavailable"
  fi
}
