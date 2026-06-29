#!/usr/bin/env bash

wl_release_manifest_digests() {
  wl_json_require

  jq -n \
    --arg registry_sha "$(wl_sha256_file "$WL_ROOT/config/commands/registry.json")" \
    --arg summary_sha "$(wl_sha256_file "$WL_ROOT/vault/02-Documentation/generated/wonderland-command-summary.md")" \
    '{command_registry_sha256:$registry_sha, command_summary_sha256:$summary_sha}'
}

wl_release_write_manifest() {
  local out="$1"
  local commit="$2"
  local registry_sha="$3"
  local summary_sha="$4"

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
    command_summary_sha256 "$summary_sha" \
    release_history "vault/08-Operations/releases/history.jsonl" \
    built_at "$(wl_timestamp)"
}

wl_release_validate_manifest_light() {
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
    and (.release_history | type == "string")
  ' "$manifest" >/dev/null \
    || wl_die "$WL_ERR_RELEASE" "release manifest missing required structural fields"

  wl_pass "release manifest structurally valid"
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

wl_release_validate_manifest() {
  local manifest="${1:-$(wl_release_dir)/latest.json}"

  if [ ! -f "$manifest" ]; then
    wl_warn "release manifest not present yet: $manifest"
    return 0
  fi

  wl_release_validate_manifest_light "$manifest"

  jq -e '
    (.command_registry_sha256 | type == "string")
    and (.command_summary_sha256 | type == "string")
  ' "$manifest" >/dev/null \
    || wl_die "$WL_ERR_RELEASE" "release manifest missing digest fields"

  [ -f "$WL_ROOT/$(jq -r '.command_registry' "$manifest")" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest command_registry path missing"

  [ -f "$WL_ROOT/$(jq -r '.command_summary' "$manifest")" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest command_summary path missing"

  [ -f "$WL_ROOT/$(jq -r '.release_history' "$manifest")" ] \
    || wl_die "$WL_ERR_RELEASE" "release manifest release_history path missing"

  wl_release_validate_manifest_digests "$manifest"

  wl_pass "release manifest valid"
}
