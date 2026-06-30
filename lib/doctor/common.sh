#!/usr/bin/env bash

wl_doctor_pass() { printf 'PASS %s\n' "$*"; }
wl_doctor_warn() { printf 'WARN %s\n' "$*"; }
wl_doctor_fail() { printf 'FAIL %s\n' "$*"; return 1; }

wl_require_file() {
  local path="$1"
  [[ -f "$path" ]] && wl_doctor_pass "file $path" || wl_doctor_fail "missing file $path"
}

wl_require_dir() {
  local path="$1"
  [[ -d "$path" ]] && wl_doctor_pass "dir $path" || wl_doctor_fail "missing dir $path"
}

wl_require_executable() {
  local path="$1"
  [[ -x "$path" ]] && wl_doctor_pass "executable $path" || wl_doctor_fail "not executable $path"
}
