#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_core() {
  local failed=0
  wl_require_file "$ROOT/lib/wl-bootstrap.sh" || failed=1
  wl_require_dir "$ROOT/lib/core" || failed=1
  wl_require_file "$ROOT/bin/wl" || failed=1
  wl_require_executable "$ROOT/bin/wl" || failed=1
  return "$failed"
}
