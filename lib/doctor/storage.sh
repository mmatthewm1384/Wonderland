#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_storage() {
  local failed=0
  wl_require_dir "$ROOT/vault" || failed=1
  [[ -d /Volumes/T7_Wonderland ]] && wl_doctor_pass "T7 mirror mounted" || wl_doctor_warn "T7 mirror not mounted"
  return "$failed"
}
