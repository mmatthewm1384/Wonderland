#!/usr/bin/env bash

set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"

WL_EVENTS_DIR="$WL_HOME/vault/08-Operations/events/runtime"
WL_RUNTIME_STATE="$WL_HOME/vault/08-Operations/state/runtime-state.json"

mkdir -p "$WL_EVENTS_DIR"

wl_event_now() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

wl_runtime_event() {
  local action="$1"
  local result="${2:-PASS}"

  local ts
  ts="$(wl_event_now)"

  local event_file
  event_file="$WL_EVENTS_DIR/${ts//:/-}-${action}.json"

  cat > "$event_file" <<JSON
{
  "timestamp": "$ts",
  "action": "$action",
  "result": "$result"
}
JSON

  cat > "$WL_RUNTIME_STATE" <<JSON
{
  "timestamp": "$ts",
  "last_action": "$action",
  "result": "$result"
}
JSON
}
