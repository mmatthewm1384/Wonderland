#!/usr/bin/env bash

wl_command_registry_file() {
  mkdir -p "$WL_ROOT/config/commands"
  printf '%s\n' "$WL_ROOT/config/commands/registry.json"
}

wl_command_phase_for() {
  local name="$1"

  case "$name" in
    wl-boot|wl-start|wl-stop) printf 'lifecycle' ;;
    wl-verify*|wl-doctor*|wl-test|wl-lint) printf 'validation' ;;
    wl-release*|wl-baseline|wl-checkpoint|wl-handoff|wl-certify) printf 'release' ;;
    wl-services*|wl-service-*|wl-nats|wl-dns|wl-vaultwarden) printf 'services' ;;
    wl-storage*) printf 'storage' ;;
    wl-runtime*|wl-state|wl-status|wl-health*) printf 'runtime' ;;
    wl-chaos*) printf 'chaos' ;;
    wl-matrix*|wl-theomatrix|wl-the-matrix|wl-spin-city|wl-agitate) printf 'matrix' ;;
    wl-vault*) printf 'vault' ;;
    wl-rootless*|wl-vm) printf 'infrastructure' ;;
    wl-firefox*|wl-wallpaper*|wl-control-center*) printf 'apps' ;;
    *) printf 'utility' ;;
  esac
}

wl_command_registry_refresh() {
  local out tmp commands_json
  out="$(wl_command_registry_file)"
  tmp="$out.tmp"

  wl_json_require

  commands_json="$(
    find "$WL_ROOT/bin" -maxdepth 1 -type f -name 'wl-*' ! -name '*.bak*' | sort |
      while IFS= read -r path; do
        local base phase
        base="$(basename "$path")"
        phase="$(wl_command_phase_for "$base")"

        jq -n \
          --arg command "$base" \
          --arg phase "$phase" \
          --arg category "$phase" \
          --arg path "bin/$base" \
          '{
            ($command): {
              command: $command,
              phase: $phase,
              category: $category,
              path: $path,
              requires: [],
              provides: [],
              json_schema: null
            }
          }'
      done |
      jq -s 'add // {}'
  )"

  local overrides_json
  overrides_json="$(
    if [ -d "$WL_ROOT/config/commands/overrides" ]; then
      find "$WL_ROOT/config/commands/overrides" -type f -name '*.json' -print0 |
        xargs -0 jq -s 'add // {}' 2>/dev/null
    else
      printf '{}'
    fi
  )"

  jq -n \
    --arg version "2.1" \
    --arg generated_at "$(wl_timestamp)" \
    --argjson commands "$commands_json" \
    --argjson overrides "$overrides_json" \
    '{
      version: $version,
      generated_at: $generated_at,
      commands: ($commands * $overrides)
    }' > "$tmp"

  jq empty "$tmp" >/dev/null || wl_die "$WL_ERR_INTERNAL" "generated invalid command registry"

  mv "$tmp" "$out"

  wl_pass "command registry refreshed"
  wl_report "$out"
  wl_result PASS
}

wl_command_registry_main() {
  local action="${1:-refresh}"

  case "$action" in
    refresh)
      wl_command_registry_refresh
      ;;
    validate)
      wl_validate_json "$(wl_command_registry_file)"
      wl_validate_json_schema "$WL_ROOT/schemas/command-registry.schema.json" "$(wl_command_registry_file)"
      wl_result PASS
      ;;
    status)
      wl_command_registry_status
      ;;
    drift)
      wl_command_registry_drift
      ;;
    summary)
      wl_command_registry_summary
      ;;
    docs)
      wl_command_registry_docs
      ;;
    audit)
      wl_command_registry_audit
      ;;
    schema-paths)
      wl_command_registry_validate_schema_paths
      ;;
    schema-files)
      wl_command_registry_validate_schema_files
      ;;
    show)
      shift || true
      wl_command_registry_show "${1:-}"
      ;;
    path)
      wl_report "$(wl_command_registry_file)"
      wl_result PASS
      ;;
    *)
      wl_die "$WL_ERR_CONFIG" "unknown command registry action: $action"
      ;;
  esac
}

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

wl_command_registry_drift() {
  local registry
  registry="$(wl_command_registry_file)"
  wl_validate_json "$registry"

  local actual registered
  actual="$(
    find "$WL_ROOT/bin" -maxdepth 1 -type f -name 'wl-*' ! -name '*.bak*' -exec basename {} \; |
      sort
  )"

  registered="$(
    jq -r '.commands | keys[]' "$registry" |
      sort
  )"

  if [ "$actual" != "$registered" ]; then
    wl_fail "command registry drift detected"

    comm -23 \
      <(printf '%s\n' "$actual") \
      <(printf '%s\n' "$registered") |
      sed 's/^/WARN missing_from_registry: /' >&2

    comm -13 \
      <(printf '%s\n' "$actual") \
      <(printf '%s\n' "$registered") |
      sed 's/^/WARN missing_from_bin: /' >&2

    wl_result FAIL
    return "$WL_ERR_VALIDATION"
  fi

  wl_pass "command registry matches bin"
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

wl_command_registry_validate_schema_paths() {
  local registry
  registry="$(wl_command_registry_file)"
  wl_validate_json "$registry"

  local missing
  missing="$(
    jq -r '.commands | to_entries[] | select(.value.json_schema != null) | .value.json_schema' "$registry" |
      sort -u |
      while IFS= read -r schema; do
        [ -f "$WL_ROOT/$schema" ] || printf '%s\n' "$schema"
      done
  )"

  if [ -n "$missing" ]; then
    printf '%s\n' "$missing" | sed 's/^/FAIL missing schema path: /' >&2
    wl_result FAIL
    return "$WL_ERR_VALIDATION"
  fi

  wl_pass "registry schema paths valid"
  wl_result PASS
}

wl_command_registry_validate_schema_files() {
  local registry
  registry="$(wl_command_registry_file)"
  wl_validate_json "$registry"

  jq -r '.commands | to_entries[] | select(.value.json_schema != null) | .value.json_schema' "$registry" |
    sort -u |
    while IFS= read -r schema; do
      wl_validate_json "$WL_ROOT/$schema"
    done

  wl_pass "registry schema files valid"
  wl_result PASS
}
