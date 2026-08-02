#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

export PACKAGE="${PACKAGE:-runtime-adapter-boundary-v1}"
export WORKSPACE="${WORKSPACE:-/Users/wonderland/Wonderland/scripts/auto-drop/packages/runtime-adapter-boundary-v1}"

exec "$WL_ROOT/scripts/auto-drop/lib/verifier.sh"
