#!/usr/bin/env bash
set -euo pipefail

WONDERLAND_ROOT="${WONDERLAND_ROOT:-${WL_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}}"
export WONDERLAND_ROOT
export PYTHONPATH="$WONDERLAND_ROOT:${PYTHONPATH:-}"

exec python3 -m wl.runtime.startup "$@"
