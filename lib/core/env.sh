#!/usr/bin/env bash

wl_root() {
  local src="${BASH_SOURCE[0]}"
  while [ -L "$src" ]; do
    src="$(readlink "$src")"
  done
  cd "$(dirname "$src")/../.." && pwd
}

wl_init_env() {
  export WL_ROOT="${WL_ROOT:-$(wl_root)}"
  export WL_RUNTIME_DIR="${WL_RUNTIME_DIR:-$WL_ROOT/runtime}"
  export WL_REPORTS_DIR="${WL_REPORTS_DIR:-$WL_ROOT/reports}"
  export WL_STATE_DIR="${WL_STATE_DIR:-$WL_ROOT/state}"
  export WL_LOGS_DIR="${WL_LOGS_DIR:-$WL_ROOT/logs}"
  mkdir -p "$WL_RUNTIME_DIR" "$WL_REPORTS_DIR" "$WL_STATE_DIR" "$WL_LOGS_DIR"
}
