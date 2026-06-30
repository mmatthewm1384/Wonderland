#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_registry() {
  local failed=0
  wl_require_dir "$ROOT/lib/core/registry" || failed=1
  for f in paths generate validate docs cli; do
    wl_require_file "$ROOT/lib/core/registry/command_registry_${f}.sh" || failed=1
  done
  return "$failed"
}
