#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_architecture() {
  local failed=0
  wl_require_file "$ROOT/lib/architecture/cli.sh" || failed=1
  wl_require_dir "$ROOT/vault/05-Registry/architecture" || failed=1
  return "$failed"
}
