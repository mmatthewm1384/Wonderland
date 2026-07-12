#!/usr/bin/env bash
set -euo pipefail
source "$WL_ROOT/lib/academy/common.sh"
source "$WL_ROOT/lib/academy/quality.sh"

academy_verify() {
  academy_quality
}
