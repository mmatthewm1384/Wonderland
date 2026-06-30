#!/usr/bin/env bash
set -euo pipefail

wl_gate_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}


wl_gate_history_append() {
  local root mode result out latest
  root="$(wl_gate_root)"
  mode="$1"
  result="$2"
  out="$root/vault/05-Registry/gates/history/gate-history.tsv"
  latest="$root/vault/05-Registry/gates/latest-status.txt"
  mkdir -p "$(dirname "$out")"

  if [[ ! -f "$out" ]]; then
    printf 'timestamp\tmode\tresult\n' > "$out"
  fi

  printf '%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$mode" "$result" >> "$out"
  {
    echo "Wonderland Gate Status"
    echo "Updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "mode=$mode"
    echo "result=$result"
  } > "$latest"
}

wl_gate_status() {
  local root latest hist
  root="$(wl_gate_root)"
  latest="$root/vault/05-Registry/gates/latest-status.txt"
  hist="$root/vault/05-Registry/gates/history/gate-history.tsv"

  if [[ -f "$latest" ]]; then
    cat "$latest"
  else
    echo "Wonderland Gate Status"
    echo "result=UNKNOWN"
    echo "No gate has completed yet."
  fi

  echo
  echo "Recent history"
  echo "--------------"
  if [[ -f "$hist" ]]; then
    tail -10 "$hist" | column -t -s $'\t'
  else
    echo "No gate history found."
  fi
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

  if [[ "$failed" -eq 0 ]]; then
    wl_gate_history_append check PASS
  else
    wl_gate_history_append check FAIL
  fi

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

  if [[ "$failed" -eq 0 ]]; then
    wl_gate_history_append promote PASS
  else
    wl_gate_history_append promote FAIL
  fi

  return "$failed"
}

wl_gate_usage() {
  cat <<'TXT'
Usage:
  wl gate check
  wl gate promote
  wl gate status

Notes:
  wl gate check runs build/validate verification only.
  wl gate promote runs check first, then explicitly promotes.
TXT
}

wl_gate_main() {
  case "${1:-check}" in
    check) wl_gate_check ;;
    promote) wl_gate_promote ;;
    status) wl_gate_status ;;
    -h|--help|help) wl_gate_usage ;;
    *) wl_gate_usage; return 2 ;;
  esac
}
