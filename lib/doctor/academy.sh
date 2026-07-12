#!/usr/bin/env bash
set -euo pipefail

wl_doctor_academy() {
  WL_ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  export WL_ROOT
  source "$WL_ROOT/lib/academy/verify.sh"
  academy_verify
}
