#!/usr/bin/env bash

: "${WL_HOME:=$HOME/Wonderland}"
: "${WL_PROFILE:=internal-light}"
: "${WL_T7_PATH:=/Volumes/T7_Wonderland}"

wl_capability_available() {
  local cap="$1"

  case "$cap" in
    internal_storage)
      [[ -d "$WL_HOME" && -d "$WL_HOME/vault" ]]
      ;;

    external_storage|t7)
      [[ -d "$WL_T7_PATH" ]]
      ;;

    media)
      [[ -d "$WL_T7_PATH/media" ]]
      ;;

    torrent)
      [[ -d "$WL_T7_PATH/media/torrents" ]]
      ;;

    runtime)
      wl_runtime_running
      ;;

    *)
      return 1
      ;;
  esac
}

wl_capability_status() {
  wl_section "Wonderland Capabilities"

  wl_capability_available internal_storage && wl_pass "internal_storage" "available" || wl_fail "internal_storage" "unavailable"
  wl_capability_available runtime && wl_pass "runtime" "available" || wl_fail "runtime" "unavailable"

  wl_capability_available external_storage && wl_pass "external_storage" "available" || wl_warn "external_storage" "unavailable in current mode"
  wl_capability_available media && wl_pass "media" "available" || wl_warn "media" "unavailable in current mode"
  wl_capability_available torrent && wl_pass "torrent" "available" || wl_warn "torrent" "unavailable in current mode"
}
