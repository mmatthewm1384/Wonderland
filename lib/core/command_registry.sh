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

  jq -n \
    --arg version "2.1" \
    --arg generated_at "$(wl_timestamp)" \
    --argjson commands "$commands_json" \
    '{
      version: $version,
      generated_at: $generated_at,
      commands: $commands
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
      wl_result PASS
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
