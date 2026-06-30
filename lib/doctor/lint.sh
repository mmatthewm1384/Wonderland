#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_lint() {
  local failed=0
  wl_require_file "$ROOT/lib/lint/cli.sh" || failed=1
  wl_require_dir "$ROOT/vault/05-Registry/lint" || true
  return "$failed"
}
