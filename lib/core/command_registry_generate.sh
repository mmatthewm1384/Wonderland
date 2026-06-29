#!/usr/bin/env bash

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
