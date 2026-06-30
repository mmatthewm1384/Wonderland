#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_chaos() {
  local failed=0
  [[ -d "$ROOT/vault/chaos" ]] && wl_doctor_pass "chaos vault present" || wl_doctor_warn "chaos vault not found"
  [[ -x "$ROOT/bin/wl-chaos-menubar" || -d "$ROOT/apps/macos/wl-chaos-menubar" ]] \
    && wl_doctor_pass "chaos menubar present" \
    || wl_doctor_warn "chaos menubar not found"
  return "$failed"
}
