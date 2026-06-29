#!/usr/bin/env bash
set -euo pipefail

WL_BOOTSTRAP_SOURCE="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
WL_ROOT="$(cd "$(dirname "$WL_BOOTSTRAP_SOURCE")/.." && pwd)"
export WL_ROOT

source "$WL_ROOT/lib/core/core.sh"
