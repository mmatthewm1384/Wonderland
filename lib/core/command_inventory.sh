#!/usr/bin/env bash

wl_command_inventory() {
  wl_pass "command inventory"

  printf '\n## Active commands\n'
  find "$WL_ROOT/bin" -maxdepth 1 -type f -name 'wl-*' ! -name '*.bak*' | sort

  printf '\n## Backup commands in bin\n'
  find "$WL_ROOT/bin" -maxdepth 1 -type f \( -name '*.bak*' -o -name '*bak.*' \) | sort || true

  wl_result PASS
}

wl_command_archive_backups() {
  local archive="$WL_ROOT/archive/command-backups/$(date -u +"%Y%m%dT%H%M%SZ")"
  mkdir -p "$archive"

  find "$WL_ROOT/bin" -maxdepth 1 -type f \( -name '*.bak*' -o -name '*bak.*' \) -print0 |
    while IFS= read -r -d '' file; do
      mv "$file" "$archive/"
      wl_pass "archived $(basename "$file")"
    done

  wl_report "$archive"
  wl_result PASS
}

wl_command_inventory_main() {
  local action="${1:-list}"

  case "$action" in
    list|status)
      wl_command_inventory
      ;;
    archive-backups)
      wl_command_archive_backups
      ;;
    *)
      wl_die "$WL_ERR_CONFIG" "unknown command inventory action: $action"
      ;;
  esac
}
