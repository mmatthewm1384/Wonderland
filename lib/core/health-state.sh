#!/usr/bin/env bash

: "${WL_HOME:=$HOME/Wonderland}"
: "${WL_RUNTIME_DIR:=$WL_HOME/runtime}"
: "${WL_HEALTH_FILE:=$WL_RUNTIME_DIR/health.json}"

wl_health_write() {
  mkdir -p "$WL_RUNTIME_DIR"

  local result="PASS"
  local rc=0

  if (( wl_corruptions > 0 )); then
    result="CORRUPT"
    rc=2
  elif (( wl_failures > 0 )); then
    result="FAIL"
    rc=1
  fi

  cat > "$WL_HEALTH_FILE" <<JSON
{
  "schema": "wonderland.runtime.health.v1",
  "pass": $wl_passes,
  "warn": $wl_warnings,
  "fail": $wl_failures,
  "corrupt": $wl_corruptions,
  "result": "$result",
  "exit_code": $rc
}
JSON
}

wl_health_dump() {
  [[ -f "$WL_HEALTH_FILE" ]] || wl_health_write
  cat "$WL_HEALTH_FILE"
}
