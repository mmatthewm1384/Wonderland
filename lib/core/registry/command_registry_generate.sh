#!/usr/bin/env bash
set -euo pipefail

wl_registry_generate() {
  local root out
  root="$(wl_registry_root)"
  out="$(wl_registry_file)"
  mkdir -p "$(dirname "$out")"

  {
    printf 'command\tpath\ttype\n'
    find "$root/bin" -maxdepth 1 -type f -perm -111 -print 2>/dev/null \
      | sort \
      | while read -r f; do
          local cmd type
          cmd="$(basename "$f")"
          if grep -q 'lib/wl-bootstrap.sh' "$f" 2>/dev/null; then
            type="bootstrap-wrapper"
          elif [[ "$(wc -l < "$f" | tr -d ' ')" -le 25 ]]; then
            type="small-wrapper-or-alias"
          else
            type="feature-command"
          fi
          printf '%s\t%s\t%s\n' "$cmd" "${f#$root/}" "$type"
        done
  } > "$out"

  printf 'PASS generated %s\n' "$out"
}
