#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_services() {
  local failed=0
  [[ -d "$ROOT/services" || -d "$ROOT/Workshop/services" ]] \
    && wl_doctor_pass "services directory present" \
    || wl_doctor_warn "services directory not found"
  return "$failed"
}
