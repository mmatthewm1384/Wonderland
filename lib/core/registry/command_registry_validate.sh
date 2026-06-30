#!/usr/bin/env bash
set -euo pipefail

wl_registry_validate() {
  local file failed=0
  file="$(wl_registry_file)"

  [[ -f "$file" ]] || {
    printf 'FAIL missing registry %s\n' "$file"
    return 1
  }

  awk -F '\t' 'NF != 3 { bad=1 } END { exit bad }' "$file" || {
    printf 'FAIL malformed registry rows\n'
    failed=1
  }

  head -1 "$file" | grep -qx $'command\tpath\ttype' || {
    printf 'FAIL invalid registry header\n'
    failed=1
  }

  [[ "$failed" -eq 0 ]] && printf 'PASS registry valid\n'
  return "$failed"
}
