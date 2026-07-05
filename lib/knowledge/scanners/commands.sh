#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

wks_scan_commands() {
  local root out count
  root="$(wks_root)"
  out="$(wks_generated_dir)/commands.md"

  count=0
  if [ -d "$root/bin" ]; then
    count="$(find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null | wc -l | tr -d ' ')"
  fi

  {
    echo "# Command Catalog"
    echo
    echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo
    echo "Executable commands: **$count**"
    echo
    echo "## Commands"
    if [ -d "$root/bin" ]; then
      find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null \
        | sed "s#^$root/bin/##" \
        | sort \
        | awk '{print "- `" $0 "`"}'
    else
      echo "- bin directory not found"
    fi
  } > "$out"

  echo "$count"
}
