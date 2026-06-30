#!/usr/bin/env bash
set -euo pipefail

wl_registry_usage() {
  cat <<'TXT'
Usage:
  wl registry generate
  wl registry validate
  wl registry docs
  wl registry list
TXT
}

wl_registry_main() {
  local ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
  . "$ROOT/lib/core/registry/command_registry_paths.sh"
  . "$ROOT/lib/core/registry/command_registry_generate.sh"
  . "$ROOT/lib/core/registry/command_registry_validate.sh"
  . "$ROOT/lib/core/registry/command_registry_docs.sh"

  case "${1:-list}" in
    generate) wl_registry_generate ;;
    validate) wl_registry_validate ;;
    docs) wl_registry_docs ;;
    list)
      [[ -f "$(wl_registry_file)" ]] || wl_registry_generate
      column -t -s $'\t' "$(wl_registry_file)"
      ;;
    -h|--help|help) wl_registry_usage ;;
    *) wl_registry_usage; return 2 ;;
  esac
}
