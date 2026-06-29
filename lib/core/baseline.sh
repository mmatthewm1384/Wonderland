#!/usr/bin/env bash

wl_baseline_dir() {
  local dir="$WL_ROOT/vault/08-Operations/baselines"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}

wl_baseline_create() {
  local ts
  ts="$(date -u +"%Y%m%dT%H%M%SZ")"

  local dir
  dir="$(wl_baseline_dir)"

  local out="$dir/baseline-$ts.json"

  wl_runtime_refresh

  wl_json_write_object "$out" \
    kind "baseline" \
    platform "wonderland" \
    version "2.1" \
    status "PASS" \
    git_commit "$(git rev-parse HEAD 2>/dev/null || printf unknown)" \
    created_at "$(wl_timestamp)"

  ln -sf "$out" "$dir/latest.json"

  wl_pass "baseline created"
  wl_report "$out"
  wl_result PASS
}

wl_baseline_main() {
  local action="${1:-create}"

  case "$action" in
    create)
      wl_baseline_create
      ;;
    *)
      wl_die "$WL_ERR_CONFIG" "unknown baseline action: $action"
      ;;
  esac
}
