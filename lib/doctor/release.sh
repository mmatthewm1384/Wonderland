#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_release() {
  local failed=0
  wl_require_file "$ROOT/lib/core/release_paths.sh" || failed=1
  wl_require_file "$ROOT/lib/core/release_history.sh" || failed=1
  wl_require_file "$ROOT/lib/core/release_manifest.sh" || failed=1
  wl_require_file "$ROOT/lib/core/release_command.sh" || failed=1
  return "$failed"
}
