#!/usr/bin/env bash

: "${WL_HOME:=$HOME/Wonderland}"
: "${WL_RUNTIME_DIR:=$WL_HOME/runtime}"
: "${WL_STATE_FILE:=$WL_RUNTIME_DIR/state.json}"
: "${WL_CAPABILITIES_FILE:=$WL_RUNTIME_DIR/capabilities.json}"

wl_state_refresh() {
  mkdir -p "$WL_RUNTIME_DIR"

  runtime_state="down"
  t7_state="detached"
  media_state="unavailable"
  torrent_state="unavailable"

  wl_runtime_running && runtime_state="running"
  wl_storage_t7_attached && t7_state="attached"
  wl_capability_available media && media_state="available"
  wl_capability_available torrent && torrent_state="available"

  cat > "$WL_STATE_FILE" <<JSON
{
  "schema": "wonderland.runtime.state.v1",
  "runtime": "$runtime_state",
  "t7": "$t7_state",
  "media": "$media_state",
  "torrent": "$torrent_state"
}
JSON

  cat > "$WL_CAPABILITIES_FILE" <<JSON
{
  "schema": "wonderland.runtime.capabilities.v1",
  "internal_storage": true,
  "external_storage": $( [[ "$t7_state" == "attached" ]] && echo true || echo false ),
  "media": $( [[ "$media_state" == "available" ]] && echo true || echo false ),
  "torrent": $( [[ "$torrent_state" == "available" ]] && echo true || echo false ),
  "runtime": $( [[ "$runtime_state" == "running" ]] && echo true || echo false )
}
JSON
}

wl_state_get() {
  local key="${1:-}"

  [[ -f "$WL_STATE_FILE" ]] || wl_state_refresh

  python3 - "$WL_STATE_FILE" "$key" <<'PY'
import json, sys
path, key = sys.argv[1], sys.argv[2]
data = json.load(open(path))
print(data.get(key, ""))
PY
}

wl_state_dump() {
  [[ -f "$WL_STATE_FILE" ]] || wl_state_refresh
  cat "$WL_STATE_FILE"
}

wl_capabilities_dump() {
  [[ -f "$WL_CAPABILITIES_FILE" ]] || wl_state_refresh
  cat "$WL_CAPABILITIES_FILE"
}
