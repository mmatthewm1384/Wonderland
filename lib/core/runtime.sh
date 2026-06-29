#!/usr/bin/env bash

wl_runtime_context="$WL_RUNTIME_DIR/context.json"
wl_runtime_state="$WL_RUNTIME_DIR/state.json"
wl_runtime_health="$WL_RUNTIME_DIR/health.json"
wl_runtime_capabilities="$WL_RUNTIME_DIR/capabilities.json"

wl_runtime_refresh() {
  wl_json_write_object "$wl_runtime_context" \
    platform "wonderland" \
    phase "runtime" \
    updated_at "$(wl_timestamp)"

  wl_json_write_object "$wl_runtime_state" \
    state "online" \
    updated_at "$(wl_timestamp)"

  wl_json_write_object "$wl_runtime_health" \
    status "healthy" \
    updated_at "$(wl_timestamp)"

  wl_json_write_object "$wl_runtime_capabilities" \
    boot "true" \
    verify "true" \
    release "true" \
    updated_at "$(wl_timestamp)"

  wl_pass "runtime artifacts refreshed"
}
