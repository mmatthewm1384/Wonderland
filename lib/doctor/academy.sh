#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

if [[ -x "$WL_ROOT/lib/academy/doctor.sh" ]]; then
  exec "$WL_ROOT/lib/academy/doctor.sh"
fi

echo "FAIL academy doctor missing: lib/academy/doctor.sh" >&2
exit 1
