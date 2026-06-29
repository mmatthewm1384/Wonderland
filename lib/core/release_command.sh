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
  mkdir -p "$(wl_release_dir)"
  touch "$(wl_release_history_file)"
  wl_release_validate

  local registry_sha summary_sha
  registry_sha="$(wl_sha256_file "$WL_ROOT/config/commands/registry.json")"
  summary_sha="$(wl_sha256_file "$WL_ROOT/vault/02-Documentation/generated/wonderland-command-summary.md")"

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
    command_registry_sha256 "$registry_sha" \
    command_summary "vault/02-Documentation/generated/wonderland-command-summary.md" \
    release_history "vault/08-Operations/releases/history.jsonl" \
    command_summary_sha256 "$summary_sha" \
    built_at "$(wl_timestamp)"

  ln -sf "$out" "$latest"

  wl_release_history_append "build" "$out"

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

  if [ -f "$stable" ]; then
    cp "$stable" "$stable.prev"
  fi

  cp "$latest" "$tmp"
  mv "$tmp" "$stable"

  wl_release_validate_manifest "$stable"

  wl_release_history_append "promote" "$stable"

  wl_release_history_append "promote" "$stable"

  wl_pass "release promoted"
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
    wl_release_validate_manifest "$latest"
  else
    wl_warn "no latest release"
  fi

  if [ -f "$stable" ]; then
    wl_report "stable=$stable"
    wl_release_validate_manifest "$stable"
  else
    wl_warn "no stable release"
  fi

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
    rollback)
      wl_release_rollback
      ;;
    validate|verify)
      wl_release_validate
      wl_result PASS
      ;;
    status)
      wl_release_status
      ;;
    history)
      wl_release_history
      ;;
    history)
      wl_release_history
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
    and (.command_registry_sha256 | type == "string")
    and (.command_summary | type == "string")
    and (.command_summary_sha256 | type == "string")
    and (.release_history | type == "string")
  ' "$manifest" >/dev/null \
    || wl_die "$WL_ERR_RELEASE" "release manifest missing required command registry fields"

  [ -f "$WL_ROOT/$(jq -r '.command_registry' "$manifest")" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest command_registry path missing"

  [ -f "$WL_ROOT/$(jq -r '.command_summary' "$manifest")" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest command_summary path missing"

  [ -f "$WL_ROOT/$(jq -r '.release_history' "$manifest")" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest release_history path missing"

  if declare -F wl_release_validate_manifest_digests >/dev/null 2>&1; then
    wl_release_validate_manifest_digests "$manifest"
  fi

  wl_pass "release manifest valid"
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

wl_release_validate_manifest_digests() {
  local manifest="${1:-$(wl_release_dir)/latest.json}"

  [ -f "$manifest" ] || return 0

  local registry summary registry_expected summary_expected registry_actual summary_actual
  registry="$(jq -r '.command_registry' "$manifest")"
  summary="$(jq -r '.command_summary' "$manifest")"
  registry_expected="$(jq -r '.command_registry_sha256' "$manifest")"
  summary_expected="$(jq -r '.command_summary_sha256' "$manifest")"

  registry_actual="$(wl_sha256_file "$WL_ROOT/$registry")"
  summary_actual="$(wl_sha256_file "$WL_ROOT/$summary")"

  [ "$registry_expected" = "$registry_actual" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest command_registry digest mismatch"

  [ "$summary_expected" = "$summary_actual" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest command_summary digest mismatch"

  wl_pass "release manifest digests valid"
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

  wl_release_history_append "rollback" "$stable"

  wl_pass "release rolled back"
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

  wl_pass "release rolled back"
  wl_report "$stable"
  wl_result PASS
}

wl_release_history_file() {
  local dir
  dir="$(wl_release_dir)"
  printf '%s\n' "$dir/history.jsonl"
}

wl_release_history_append() {
  local action="$1"
  local manifest="${2:-}"
  local file
  file="$(wl_release_history_file)"

  jq -n \
    --arg at "$(wl_timestamp)" \
    --arg action "$action" \
    --arg manifest "$manifest" \
    --arg git_commit "$(git rev-parse --short HEAD 2>/dev/null || printf unknown)" \
    '{
      at: $at,
      action: $action,
      manifest: $manifest,
      git_commit: $git_commit
    }' >> "$file"
}

wl_release_history() {
  local file
  file="$(wl_release_history_file)"

  [ -f "$file" ] || {
    wl_warn "no release history"
    wl_result PASS
    return 0
  }

  tail -20 "$file"
  wl_result PASS
}

wl_release_history_file() {
  local dir
  dir="$(wl_release_dir)"
  printf '%s\n' "$dir/history.jsonl"
}

wl_release_history_append() {
  local action="$1"
  local manifest="${2:-}"
  local file
  file="$(wl_release_history_file)"

  jq -n \
    --arg at "$(wl_timestamp)" \
    --arg action "$action" \
    --arg manifest "$manifest" \
    --arg git_commit "$(git rev-parse --short HEAD 2>/dev/null || printf unknown)" \
    '{
      at: $at,
      action: $action,
      manifest: $manifest,
      git_commit: $git_commit
    }' >> "$file"
}

wl_release_history() {
  local file
  file="$(wl_release_history_file)"

  [ -f "$file" ] || {
    wl_warn "no release history"
    wl_result PASS
    return 0
  }

  tail -20 "$file"
  wl_result PASS
}
