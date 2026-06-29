#!/usr/bin/env bash

wl_doctor_core() {
  "$WL_ROOT/bin/wl-core-22-doctor"
}

wl_doctor_main() {
  local target="${1:-core}"

  case "$target" in
    core)
      wl_doctor_core
      ;;
    registry)
      wl_command_registry_doctor
      ;;
    release)
      wl_release_validate_all
      ;;
    all)
      wl_doctor_core
      wl_command_registry_doctor
      wl_release_validate_all
      ;;
    *)
      wl_die "$WL_ERR_CONFIG" "unknown doctor target: $target"
      ;;
  esac
}
