#!/usr/bin/env bash
set -euo pipefail

wl_gate_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_gate_run_step() {
  local name="$1"
  shift

  echo
  echo "== $name =="
  if "$@"; then
    echo "PASS $name"
  else
    local rc=$?
    echo "FAIL $name rc=$rc"
    return "$rc"
  fi
}

wl_gate_check() {
  local root out failed=0
  root="$(wl_gate_root)"
  out="$root/vault/05-Registry/gates/latest-gate-check.txt"
  mkdir -p "$(dirname "$out")"

  {
    echo "Wonderland Platform Gate Check"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

    wl_gate_run_step "fix safe apply" "$root/bin/wl" fix apply --safe || failed=1
    wl_gate_run_step "lint all" "$root/bin/wl" lint all || failed=1
    wl_gate_run_step "doctor all" "$root/bin/wl" doctor all || failed=1
    wl_gate_run_step "verify" "$root/bin/wl" verify || failed=1
    wl_gate_run_step "release build" "$root/bin/wl" release build || failed=1
    wl_gate_run_step "release validate" "$root/bin/wl" release validate || failed=1
    wl_gate_run_step "verify final" "$root/bin/wl" verify || failed=1

    echo
    [[ "$failed" -eq 0 ]] && echo "RESULT PASS" || echo "RESULT FAIL"
  } | tee "$out"

  return "$failed"
}

wl_gate_promote() {
  local root out failed=0
  root="$(wl_gate_root)"
  out="$root/vault/05-Registry/gates/latest-gate-promote.txt"
  mkdir -p "$(dirname "$out")"

  {
    echo "Wonderland Platform Gate Promote"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

    wl_gate_run_step "pre-promote check" "$root/bin/wl" gate check || failed=1

    if [[ "$failed" -eq 0 ]]; then
      wl_gate_run_step "release promote" "$root/bin/wl" release promote || failed=1
      wl_gate_run_step "release validate after promote" "$root/bin/wl" release validate || failed=1
      wl_gate_run_step "verify after promote" "$root/bin/wl" verify || failed=1
    fi

    echo
    [[ "$failed" -eq 0 ]] && echo "RESULT PASS" || echo "RESULT FAIL"
  } | tee "$out"

  return "$failed"
}

wl_gate_usage() {
  cat <<'TXT'
Usage:
  wl gate check
  wl gate promote

Notes:
  wl gate check runs build/validate verification only.
  wl gate promote runs check first, then explicitly promotes.
TXT
}

wl_gate_main() {
  case "${1:-check}" in
    check) wl_gate_check ;;
    promote) wl_gate_promote ;;
    -h|--help|help) wl_gate_usage ;;
    *) wl_gate_usage; return 2 ;;
  esac
}
