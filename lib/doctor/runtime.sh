#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_runtime() {
  local failed=0
  command -v nerdctl >/dev/null 2>&1 && wl_doctor_pass "nerdctl available" || wl_doctor_warn "nerdctl not found"
  command -v limactl >/dev/null 2>&1 && wl_doctor_pass "limactl available" || wl_doctor_warn "limactl not found"
  wl_require_dir "$ROOT/runtime" || true
  return "$failed"
}
