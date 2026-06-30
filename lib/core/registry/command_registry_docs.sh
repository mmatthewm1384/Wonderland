#!/usr/bin/env bash
set -euo pipefail

wl_registry_docs() {
  local in out
  in="$(wl_registry_file)"
  out="$(wl_registry_docs_file)"
  [[ -f "$in" ]] || wl_registry_generate

  {
    printf '# Wonderland Command Registry\n\n'
    printf '| Command | Path | Type |\n'
    printf '|---|---|---|\n'
    tail -n +2 "$in" | awk -F '\t' '{ printf "| `%s` | `%s` | `%s` |\n", $1, $2, $3 }'
  } > "$out"

  printf 'PASS docs generated %s\n' "$out"
}
