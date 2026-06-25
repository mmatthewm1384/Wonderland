#!/usr/bin/env bash
# Wonderland authority resolver.
# Source this from shell scripts.
set -euo pipefail

export WL_HOME="${WL_HOME:-$HOME/Wonderland}"
export WL_AUTHORITY_ROOT="${WL_AUTHORITY_ROOT:-$WL_HOME}"
export WL_WORKSHOP_ROOT="${WL_WORKSHOP_ROOT:-$HOME/Workshop}"
export WL_RUNTIME_ROOT="${WL_RUNTIME_ROOT:-$HOME/Runtime}"
export WL_ARCHIVE_ROOT="${WL_ARCHIVE_ROOT:-$HOME/Archive}"
export WL_MEDIA_ROOT="${WL_MEDIA_ROOT:-$HOME/Media}"

wl_root() {
  printf '%s\n' "$WL_AUTHORITY_ROOT"
}

wl_path() {
  local rel="${1:-}"
  printf '%s/%s\n' "$WL_AUTHORITY_ROOT" "${rel#/}"
}
