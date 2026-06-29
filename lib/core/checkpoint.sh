#!/usr/bin/env bash

wl_checkpoint_dir() {
  local dir="$WL_ROOT/vault/08-Operations/checkpoints"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}

wl_checkpoint_create() {
  local ts dir out latest commit
  ts="$(date -u +"%Y%m%dT%H%M%SZ")"
  dir="$(wl_checkpoint_dir)"
  out="$dir/checkpoint-$ts.json"
  latest="$dir/latest.json"
  commit="$(git rev-parse --short HEAD 2>/dev/null || printf unknown)"

  wl_validate_runtime

  wl_json_write_object "$out" \
    kind "checkpoint" \
    platform "wonderland" \
    version "2.1" \
    status "PASS" \
    git_commit "$commit" \
    created_at "$(wl_timestamp)"

  ln -sf "$out" "$latest"

  wl_pass "checkpoint created"
  wl_report "$out"
  wl_result PASS
}

wl_checkpoint_main() {
  local action="${1:-create}"

  case "$action" in
    create)
      wl_checkpoint_create
      ;;
    *)
      wl_die "$WL_ERR_CONFIG" "unknown checkpoint action: $action"
      ;;
  esac
}
