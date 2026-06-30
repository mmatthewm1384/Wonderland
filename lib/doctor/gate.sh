#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_gate() {
  local failed=0
  wl_require_file "$ROOT/lib/gate/cli.sh" || failed=1
  wl_require_dir "$ROOT/vault/05-Registry/gates" || failed=1
  return "$failed"
}
