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
  wl doctor architecture
  wl doctor lint
  wl doctor gate
  wl doctor engineering
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

  [[ -f "$ROOT/lib/doctor/architecture.sh" ]] && . "$ROOT/lib/doctor/architecture.sh"
  [[ -f "$ROOT/lib/doctor/lint.sh" ]] && . "$ROOT/lib/doctor/lint.sh"
  [[ -f "$ROOT/lib/doctor/gate.sh" ]] && . "$ROOT/lib/doctor/gate.sh"
  [[ -f "$ROOT/lib/doctor/engineering.sh" ]] && . "$ROOT/lib/doctor/engineering.sh"

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
    architecture)
      if declare -F wl_doctor_architecture >/dev/null; then
        wl_doctor_architecture
      else
        echo "WARN doctor architecture module not installed"
      fi
      ;;
    lint)
      if declare -F wl_doctor_lint >/dev/null; then
        wl_doctor_lint
      else
        echo "WARN doctor lint module not installed"
      fi
      ;;
    gate)
      if declare -F wl_doctor_gate >/dev/null; then
        wl_doctor_gate
      else
        echo "WARN doctor gate module not installed"
      fi
      ;;
    engineering)
      if declare -F wl_doctor_engineering >/dev/null; then
        wl_doctor_engineering
      else
        echo "WARN doctor engineering module not installed"
      fi
      ;;
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

      if declare -F wl_doctor_architecture >/dev/null; then
        wl_doctor_architecture || failed=1
      fi

      if declare -F wl_doctor_lint >/dev/null; then
        wl_doctor_lint || failed=1
      fi

      if declare -F wl_doctor_gate >/dev/null; then
        wl_doctor_gate || failed=1
      fi

      if declare -F wl_doctor_engineering >/dev/null; then
        wl_doctor_engineering || failed=1
      fi

      [[ "$failed" -eq 0 ]] && echo "RESULT PASS" || echo "RESULT FAIL"
      return "$failed"
      ;;
    -h|--help|help) wl_doctor_usage ;;
    *) wl_doctor_usage; return 2 ;;
  esac
}
