#!/usr/bin/env sh

WL_VERSION="0.1.0"
WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
WL_LOG_DIR="$WL_ROOT/logs"

wl_log() {
  mkdir -p "$WL_LOG_DIR"
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >> "$WL_LOG_DIR/wl.log"
}

wl_info() {
  printf '%s\n' "$*"
  wl_log "INFO $*"
}

wl_error() {
  printf 'ERROR: %s\n' "$*" >&2
  wl_log "ERROR $*"
}

wl_require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    wl_error "Missing dependency: $1"
    exit 3
  fi
}
