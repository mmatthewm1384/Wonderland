#!/usr/bin/env bash

wl_pass()   { printf 'PASS %s\n' "$*"; }
wl_warn()   { printf 'WARN %s\n' "$*" >&2; }
wl_fail()   { printf 'FAIL %s\n' "$*" >&2; }
wl_report() { printf 'REPORT %s\n' "$*"; }
wl_result() { printf 'RESULT %s\n' "$*"; }

wl_die() {
  local code="${1:-1}"
  shift || true
  wl_fail "$*"
  wl_result FAIL
  exit "$code"
}
