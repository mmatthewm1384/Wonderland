#!/usr/bin/env bash
# Wonderland shared shell library
# Contract:
#   PASS / WARN -> exit 0
#   FAIL        -> exit 1
#   CORRUPT     -> exit 2
#   ERROR       -> exit 3

: "${WL_ROOT:=$HOME/Wonderland}"
: "${WL_MODE:=light}"
: "${WL_T7_PATH:=/Volumes/T7_Wonderland}"

WL_EXIT_PASS=0
WL_EXIT_WARN=0
WL_EXIT_FAIL=1
WL_EXIT_CORRUPT=2
WL_EXIT_ERROR=3

wl_passes=0
wl_warnings=0
wl_failures=0
wl_corruptions=0

wl_section() {
  printf '\n== %s ==\n' "$*"
}

wl_pass() {
  wl_passes=$((wl_passes + 1))
  printf 'PASS %-24s %s\n' "$1" "${2:-}"
}

wl_warn() {
  wl_warnings=$((wl_warnings + 1))
  printf 'WARN %-24s %s\n' "$1" "${2:-}"
}

wl_fail() {
  wl_failures=$((wl_failures + 1))
  printf 'FAIL %-24s %s\n' "$1" "${2:-}"
}

wl_corrupt() {
  wl_corruptions=$((wl_corruptions + 1))
  printf 'CORRUPT %-21s %s\n' "$1" "${2:-}"
}

wl_required_path() {
  local label="$1"
  local path="$2"

  if [[ -e "$path" ]]; then
    wl_pass "$label" "$path"
  else
    wl_fail "$label" "missing: $path"
  fi
}

wl_optional_path() {
  local label="$1"
  local path="$2"

  if [[ -e "$path" ]]; then
    wl_pass "$label" "$path"
  else
    wl_warn "$label" "unavailable: $path"
  fi
}

wl_t7_status() {
  if [[ -d "$WL_T7_PATH" ]]; then
    wl_pass "t7" "connected: $WL_T7_PATH"
  else
    wl_warn "t7" "not connected; continuing in internal/light mode"
  fi
}


wl_exit() {
  wl_result
  exit $?
}

wl_run_required() {
  local label="$1"
  shift

  if "$@"; then
    wl_pass "$label"
  else
    wl_fail "$label" "command failed: $*"
  fi
}

wl_run_optional() {
  local label="$1"
  shift

  if "$@"; then
    wl_pass "$label"
  else
    wl_warn "$label" "optional command unavailable: $*"
  fi
}
