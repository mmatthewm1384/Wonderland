#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_matrix() {
  local failed=0
  [[ -x "$ROOT/bin/wl-matrix" || -d "$ROOT/apps" ]] \
    && wl_doctor_pass "matrix command/app surface present" \
    || wl_doctor_warn "matrix surface not found"
  [[ -d "$ROOT/vault/08-Operations/matrix" ]] \
    && wl_doctor_pass "matrix operation vault present" \
    || wl_doctor_warn "matrix operation vault not found"
  return "$failed"
}
