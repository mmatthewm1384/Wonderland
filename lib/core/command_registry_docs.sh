#!/usr/bin/env bash

wl_command_registry_status() {
  local registry
  registry="$(wl_command_registry_file)"
  wl_validate_json "$registry"

  jq -r '
    .commands
    | to_entries
    | group_by(.value.category)
    | map({category: .[0].value.category, count: length})
    | sort_by(.category)
    | .[]
    | "REPORT category=\(.category) count=\(.count)"
  ' "$registry"

  jq -r '
    .commands
    | length
    | "REPORT total_commands=\(.)"
  ' "$registry"

  wl_result PASS
}

wl_command_registry_show() {
  local name="${1:-}"
  local registry
  registry="$(wl_command_registry_file)"

  [ -n "$name" ] || wl_die "$WL_ERR_CONFIG" "missing command name"
  wl_validate_json "$registry"

  jq -e --arg name "$name" '.commands[$name]' "$registry" >/dev/null \
    || wl_die "$WL_ERR_VALIDATION" "unknown command: $name"

  jq --arg name "$name" '.commands[$name]' "$registry"
  wl_result PASS
}

wl_command_registry_summary() {
  local registry out
  registry="$(wl_command_registry_file)"
  out="$WL_ROOT/vault/02-Documentation/generated/wonderland-command-summary.md"

  wl_validate_json "$registry"
  mkdir -p "$(dirname "$out")"

  {
    printf '# Wonderland Command Summary\n\n'
    printf 'Generated: %s\n\n' "$(wl_timestamp)"
    printf '## Totals\n\n'

    jq -r '
      .commands
      | length
      | "- Total commands: \(.)"
    ' "$registry"

    printf '\n## Categories\n\n'

    jq -r '
      .commands
      | to_entries
      | group_by(.value.category)
      | map({category: .[0].value.category, count: length})
      | sort_by(.category)
      | .[]
      | "- \(.category): \(.count)"
    ' "$registry"

    printf '\n## Commands\n\n'

    jq -r '
      .commands
      | to_entries
      | sort_by(.key)
      | .[]
      | "### \(.key)\n\n- Path: `\(.value.path)`\n- Category: `\(.value.category)`\n- Phase: `\(.value.phase)`\n"
    ' "$registry"
  } > "$out"

  wl_pass "command summary generated"
  wl_report "$out"
  wl_result PASS
}

wl_command_registry_docs() {
  wl_command_registry_refresh >/dev/null
  wl_command_registry_drift >/dev/null
  wl_validate_json_schema "$WL_ROOT/schemas/command-registry.schema.json" "$(wl_command_registry_file)"
  wl_command_registry_validate_schema_paths >/dev/null
  wl_command_registry_validate_schema_files >/dev/null
  wl_command_registry_summary
}

wl_command_registry_audit() {
  local registry
  registry="$(wl_command_registry_file)"
  wl_validate_json "$registry"

  jq -r '
    .commands
    | to_entries
    | sort_by(.key)
    | .[]
    | select(
        (.value.category == "utility")
        or (.value.requires | length == 0)
        or (.value.provides | length == 0)
      )
    | "WARN weak_metadata command=\(.key) category=\(.value.category) requires=\(.value.requires|length) provides=\(.value.provides|length)"
  ' "$registry" >&2

  wl_pass "command metadata audit complete"
  wl_result PASS
}

wl_command_registry_doctor() {
  wl_command_registry_refresh
  wl_command_registry_drift
  wl_validate_json_schema "$WL_ROOT/schemas/command-registry.schema.json" "$(wl_command_registry_file)"
  wl_command_registry_validate_schema_paths
  wl_command_registry_validate_schema_files
  wl_command_registry_summary
  wl_command_registry_audit
  wl_pass "command registry doctor complete"
  wl_result PASS
}
