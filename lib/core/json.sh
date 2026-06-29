#!/usr/bin/env bash

wl_json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read().rstrip("\n")))' <<<"${1:-}"
}

wl_json_bool() {
  case "${1:-}" in
    1|true|TRUE|yes|YES|available|running|attached|up)
      echo "true"
      ;;
    *)
      echo "false"
      ;;
  esac
}

wl_json_status_block() {
  local result="${1:-PASS}"
  local warnings="${2:-0}"
  local failures="${3:-0}"

  cat <<JSON
{
  "result": "$result",
  "warnings": $warnings,
  "failures": $failures
}
JSON
}
