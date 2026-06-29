#!/usr/bin/env bash

wl_json_require() {
  command -v jq >/dev/null 2>&1 || {
    printf 'FAIL jq required for JSON generation\n' >&2
    exit 2
  }
}

wl_json_write_object() {
  local out="$1"
  shift
  wl_json_require

  local jq_args=()
  local jq_expr='{'
  local first=1

  while [ "$#" -gt 1 ]; do
    local key="$1"
    local value="$2"
    shift 2

    jq_args+=(--arg "$key" "$value")

    if [ "$first" -eq 1 ]; then
      first=0
    else
      jq_expr+=','
    fi

    jq_expr+="\"$key\":\$$key"
  done

  jq_expr+='}'

  jq -n "${jq_args[@]}" "$jq_expr" > "$out"
}
