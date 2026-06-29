#!/usr/bin/env bash

wl_certify_dir() {
  local dir="$WL_ROOT/vault/08-Operations/certifications"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}

wl_certify_create() {
  local ts dir out latest commit
  ts="$(date -u +"%Y%m%dT%H%M%SZ")"
  dir="$(wl_certify_dir)"
  out="$dir/certification-$ts.json"
  latest="$dir/latest.json"
  commit="$(git rev-parse --short HEAD 2>/dev/null || printf unknown)"

  wl_validate_runtime
  wl_release_validate

  wl_json_write_object "$out" \
    kind "certification" \
    platform "wonderland" \
    version "2.1" \
    status "PASS" \
    git_commit "$commit" \
    certified_at "$(wl_timestamp)"

  ln -sf "$out" "$latest"

  wl_pass "certification created"
  wl_report "$out"
  wl_result PASS
}

wl_certify_main() {
  local action="${1:-create}"

  case "$action" in
    create|platform|core)
      wl_certify_create
      ;;
    *)
      wl_die "$WL_ERR_CONFIG" "unknown certify action: $action"
      ;;
  esac
}
