#!/usr/bin/env bash

wl_release_build() {
  local ts out latest commit registry_sha summary_sha
  ts="$(date -u +"%Y%m%dT%H%M%SZ")"
  out="$(wl_release_manifest_path "$ts")"
  latest="$(wl_release_dir)/latest.json"
  commit="$(git rev-parse --short HEAD 2>/dev/null || printf unknown)"

  wl_validate_runtime
  mkdir -p "$(wl_release_dir)"
  touch "$(wl_release_history_file)"
  wl_release_validate_history

  registry_sha="$(wl_sha256_file "$WL_ROOT/config/commands/registry.json")"
  summary_sha="$(wl_sha256_file "$WL_ROOT/vault/02-Documentation/generated/wonderland-command-summary.md")"

  wl_release_write_manifest "$out" "$commit" "$registry_sha" "$summary_sha"
  ln -sf "$out" "$latest"

  wl_release_history_append "build" "$out"

  wl_pass "release built"
  wl_report "$out"
  wl_result PASS
}

wl_release_promote() {
  local dir latest stable tmp
  dir="$(wl_release_dir)"
  latest="$dir/latest.json"
  stable="$dir/stable.json"
  tmp="$dir/stable.json.tmp"

  [ -f "$latest" ] || wl_die "$WL_ERR_RELEASE" "missing latest release manifest"

  wl_release_validate_manifest "$latest"

  if [ -f "$stable" ]; then
    cp "$stable" "$stable.prev"
  fi

  cp "$latest" "$tmp"
  mv "$tmp" "$stable"

  wl_release_validate_manifest "$stable"
  wl_release_history_append "promote" "$stable"

  wl_pass "release promoted"
  wl_report "$stable"
  wl_result PASS
}

wl_release_rollback() {
  local dir stable previous tmp
  dir="$(wl_release_dir)"
  stable="$dir/stable.json"
  previous="$dir/stable.json.prev"
  tmp="$dir/stable.json.rollback.tmp"

  [ -f "$previous" ] || wl_die "$WL_ERR_RELEASE" "missing previous stable release"

  wl_release_validate_manifest "$previous"

  cp "$previous" "$tmp"
  mv "$tmp" "$stable"

  wl_release_validate_manifest "$stable"
  wl_release_history_append "rollback" "$stable"

  wl_pass "release rolled back"
  wl_report "$stable"
  wl_result PASS
}

wl_release_status() {
  local dir latest stable
  dir="$(wl_release_dir)"
  latest="$dir/latest.json"
  stable="$dir/stable.json"

  if [ -f "$latest" ]; then
    wl_report "latest=$latest"
    wl_release_validate_manifest_light "$latest"
  else
    wl_warn "no latest release"
  fi

  if [ -f "$stable" ]; then
    wl_report "stable=$stable"
    wl_release_validate_manifest_light "$stable"
  else
    wl_warn "no stable release"
  fi

  wl_release_validate_history
  wl_result PASS
}

wl_release_validate_all() {
  local dir latest stable
  dir="$(wl_release_dir)"
  latest="$dir/latest.json"
  stable="$dir/stable.json"

  wl_release_validate_history

  if [ -f "$latest" ]; then
    wl_release_validate_manifest "$latest"
  else
    wl_warn "latest release missing"
  fi

  if [ -f "$stable" ]; then
    wl_release_validate_manifest "$stable"
  else
    wl_warn "stable release missing"
  fi

  wl_pass "release artifacts validated"
  wl_result PASS
}

wl_release_main() {
  local action="${1:-status}"

  case "$action" in
    build)
      wl_release_build
      ;;
    promote)
      wl_release_promote
      ;;
    rollback)
      wl_release_rollback
      ;;
    validate|verify)
      wl_release_validate_all
      ;;
    status)
      wl_release_status
      ;;
    history)
      wl_release_history
      ;;
    repair-history)
      wl_release_repair_history
      ;;
    *)
      wl_die "$WL_ERR_CONFIG" "unknown release action: $action"
      ;;
  esac
}
