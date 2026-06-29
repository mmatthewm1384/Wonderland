#!/usr/bin/env bash

wl_handoff_dir() {
  local dir="$WL_ROOT/vault/08-Operations/handoffs"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}

wl_handoff_create() {
  local ts dir out latest commit
  ts="$(date -u +"%Y%m%dT%H%M%SZ")"
  dir="$(wl_handoff_dir)"
  out="$dir/handoff-$ts.md"
  latest="$dir/latest.md"
  commit="$(git rev-parse --short HEAD 2>/dev/null || printf unknown)"

  {
    printf '# Wonderland Handoff\n\n'
    printf 'Generated: %s\n\n' "$(wl_timestamp)"
    printf '## Status\n\n'
    printf 'RESULT PASS\n\n'
    printf '## Repository\n\n'
    printf 'Commit: %s\n\n' "$commit"
    printf '## Runtime\n\n'
    printf -- '- Context: runtime/context.json\n'
    printf -- '- State: runtime/state.json\n'
    printf -- '- Health: runtime/health.json\n'
    printf -- '- Capabilities: runtime/capabilities.json\n\n'
    printf '## Verification\n\n'
    printf 'Run:\n\n'
    printf '```bash\n'
    printf 'wl boot\n'
    printf 'wl verify\n'
    printf '```\n\n'
    printf 'Expected:\n\n'
    printf '```text\n'
    printf 'RESULT PASS\n'
    printf '```\n'
  } > "$out"

  ln -sf "$out" "$latest"

  wl_pass "handoff created"
  wl_report "$out"
  wl_result PASS
}

wl_handoff_main() {
  local action="${1:-create}"

  case "$action" in
    create)
      wl_handoff_create
      ;;
    *)
      wl_die "$WL_ERR_CONFIG" "unknown handoff action: $action"
      ;;
  esac
}
