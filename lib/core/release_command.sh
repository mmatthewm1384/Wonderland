#!/usr/bin/env bash

wl_release_dir() {
  local dir="$WL_ROOT/vault/08-Operations/releases"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}

wl_release_manifest_path() {
  local ts="$1"
  local dir
  dir="$(wl_release_dir)"
  printf '%s/release-%s.json\n' "$dir" "$ts"
}

wl_release_build() {
  local ts out latest commit
  ts="$(date -u +"%Y%m%dT%H%M%SZ")"
  out="$(wl_release_manifest_path "$ts")"
  latest="$(wl_release_dir)/latest.json"
  commit="$(git rev-parse --short HEAD 2>/dev/null || printf unknown)"

  wl_validate_runtime
  wl_release_validate

  wl_json_write_object "$out" \
    kind "release" \
    platform "wonderland" \
    version "2.1" \
    status "built" \
    git_commit "$commit" \
    runtime_context "runtime/context.json" \
    runtime_state "runtime/state.json" \
    runtime_health "runtime/health.json" \
    runtime_capabilities "runtime/capabilities.json" \
    command_registry "config/commands/registry.json" \
    command_summary "vault/02-Documentation/generated/wonderland-command-summary.md" \
    built_at "$(wl_timestamp)"

  ln -sf "$out" "$latest"

  wl_pass "release built"
  wl_report "$out"
  wl_result PASS
}

wl_release_promote() {
  local dir latest stable
  dir="$(wl_release_dir)"
  latest="$dir/latest.json"
  stable="$dir/stable.json"

  [ -f "$latest" ] || wl_die "$WL_ERR_RELEASE" "missing latest release manifest"

  cp "$latest" "$stable"

  wl_pass "release promoted"
  wl_report "$stable"
  wl_result PASS
}

wl_release_status() {
  local dir latest stable
  dir="$(wl_release_dir)"
  latest="$dir/latest.json"
  stable="$dir/stable.json"

  [ -f "$latest" ] && wl_report "latest=$latest" || wl_warn "no latest release"
  [ -f "$stable" ] && wl_report "stable=$stable" || wl_warn "no stable release"

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
    validate|verify)
      wl_release_validate
      wl_result PASS
      ;;
    status)
      wl_release_status
      ;;
    *)
      wl_die "$WL_ERR_CONFIG" "unknown release action: $action"
      ;;
  esac
}

wl_release_validate_manifest() {
  local manifest="${1:-$(wl_release_dir)/latest.json}"

  if [ ! -f "$manifest" ]; then
    wl_warn "release manifest not present yet: $manifest"
    return 0
  fi

  wl_validate_json "$manifest"

  jq -e '
    .kind == "release"
    and .platform == "wonderland"
    and (.command_registry | type == "string")
    and (.command_summary | type == "string")
  ' "$manifest" >/dev/null \
    || wl_die "$WL_ERR_RELEASE" "release manifest missing required command registry fields"

  [ -f "$WL_ROOT/$(jq -r '.command_registry' "$manifest")" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest command_registry path missing"

  [ -f "$WL_ROOT/$(jq -r '.command_summary' "$manifest")" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest command_summary path missing"

  wl_pass "release manifest valid"
}

wl_release_validate_manifest() {
  local manifest="${1:-$(wl_release_dir)/latest.json}"

  wl_validate_json "$manifest"

  jq -e '
    .kind == "release"
    and .platform == "wonderland"
    and (.command_registry | type == "string")
    and (.command_summary | type == "string")
  ' "$manifest" >/dev/null \
    || wl_die "$WL_ERR_RELEASE" "release manifest missing required command registry fields"

  [ -f "$WL_ROOT/$(jq -r '.command_registry' "$manifest")" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest command_registry path missing"

  [ -f "$WL_ROOT/$(jq -r '.command_summary' "$manifest")" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest command_summary path missing"

  wl_pass "release manifest valid"
}
