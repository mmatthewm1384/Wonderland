#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/doctor/common.sh"

wl_doctor_engineering() {
  local failed=0

  for f in \
    "$ROOT/lib/status/cli.sh" \
    "$ROOT/lib/checkpoint/cli.sh" \
    "$ROOT/lib/rollback/cli.sh" \
    "$ROOT/lib/help/cli.sh" \
    "$ROOT/lib/fix/cli.sh" \
    "$ROOT/lib/report/cli.sh" \
    "$ROOT/lib/gate/cli.sh" \
    "$ROOT/lib/core/dispatch/engineering.sh"
  do
    wl_require_file "$f" || failed=1
  done

  for d in \
    "$ROOT/vault/05-Registry/status" \
    "$ROOT/vault/05-Registry/checkpoints" \
    "$ROOT/vault/05-Registry/rollback" \
    "$ROOT/vault/05-Registry/docs" \
    "$ROOT/vault/05-Registry/fix" \
    "$ROOT/vault/05-Registry/reports" \
    "$ROOT/vault/05-Registry/gates"
  do
    wl_require_dir "$d" || failed=1
  done

  return "$failed"
}
