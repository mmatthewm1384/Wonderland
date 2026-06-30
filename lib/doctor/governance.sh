#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_governance() {
  local failed=0
  [[ -d "$ROOT/vault/05-Registry" || -d "$ROOT/vault/06-Governance" ]] \
    && wl_doctor_pass "governance registry present" \
    || wl_doctor_warn "governance registry not found"
  return "$failed"
}
