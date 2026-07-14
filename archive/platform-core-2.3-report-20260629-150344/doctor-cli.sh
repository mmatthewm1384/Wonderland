#!/usr/bin/env bash
set -euo pipefail

wl_doctor_usage() {
  cat <<'TXT'
Usage:
  wl doctor core
  wl doctor registry
  wl doctor release
  wl doctor runtime
  wl doctor services
  wl doctor storage
  wl doctor governance
  wl doctor chaos
  wl doctor matrix
  wl doctor all
TXT
}

wl_doctor_main() {
  local ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  local target="${1:-all}"
  local failed=0

  . "$ROOT/lib/doctor/core.sh"
  . "$ROOT/lib/doctor/registry.sh"
  . "$ROOT/lib/doctor/release.sh"
  . "$ROOT/lib/doctor/runtime.sh"
  . "$ROOT/lib/doctor/services.sh"
  . "$ROOT/lib/doctor/storage.sh"
  . "$ROOT/lib/doctor/governance.sh"
  . "$ROOT/lib/doctor/chaos.sh"
  . "$ROOT/lib/doctor/matrix.sh"

  case "$target" in
    core) wl_doctor_core ;;
    registry) wl_doctor_registry ;;
    release) wl_doctor_release ;;
    runtime) wl_doctor_runtime ;;
    services) wl_doctor_services ;;
    storage) wl_doctor_storage ;;
    governance) wl_doctor_governance ;;
    chaos) wl_doctor_chaos ;;
    matrix) wl_doctor_matrix ;;
    all)
      for check in \
        wl_doctor_core \
        wl_doctor_registry \
        wl_doctor_release \
        wl_doctor_runtime \
        wl_doctor_services \
        wl_doctor_storage \
        wl_doctor_governance \
        wl_doctor_chaos \
        wl_doctor_matrix
      do
        "$check" || failed=1
      done
      [[ "$failed" -eq 0 ]] && echo "RESULT PASS" || echo "RESULT FAIL"
      return "$failed"
      ;;
    -h|--help|help) wl_doctor_usage ;;
    *) wl_doctor_usage; return 2 ;;
  esac
}
