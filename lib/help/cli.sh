#!/usr/bin/env bash
set -euo pipefail

wl_help_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_help_index() {
  local root out
  root="$(wl_help_root)"
  out="$root/vault/05-Registry/docs/platform-engineering-commands.md"
  mkdir -p "$(dirname "$out")"

  {
    echo "# Wonderland Platform Engineering Commands"
    echo
    echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "## Health"
    echo
    echo '```bash'
    echo "wl status"
    echo "wl doctor all"
    echo "wl verify"
    echo "wl gate check"
    echo '```'
    echo
    echo "## Architecture"
    echo
    echo '```bash'
    echo "wl architecture report"
    echo "wl architecture graph"
    echo "wl architecture snapshot"
    echo "wl architecture score"
    echo "wl architecture drift"
    echo "wl architecture functions"
    echo "wl architecture imports"
    echo "wl architecture duplicates"
    echo "wl architecture cycles"
    echo '```'
    echo
    echo "## Inventory and Registry"
    echo
    echo '```bash'
    echo "wl inventory"
    echo "wl registry generate"
    echo "wl registry validate"
    echo "wl registry docs"
    echo "wl registry list"
    echo '```'
    echo
    echo "## Maintenance"
    echo
    echo '```bash'
    echo "wl lint all"
    echo "wl fix plan"
    echo "wl fix apply --safe"
    echo "wl migrate all"
    echo "wl refactor plan 200"
    echo '```'
    echo
    echo "## Checkpoint and Recovery"
    echo
    echo '```bash'
    echo "wl checkpoint latest"
    echo "wl checkpoint validate"
    echo "wl checkpoint export"
    echo "wl rollback plan"
    echo '```'
    echo
    echo "## Reporting"
    echo
    echo '```bash'
    echo "wl report"
    echo "wl status handoff"
    echo '```'
  } > "$out"

  cat "$out"
  echo
  echo "PASS help index $out"
}

wl_help_usage() {
  cat <<'TXT'
Usage:
  wl help
  wl help index
TXT
}

wl_help_main() {
  case "${1:-index}" in
    index) wl_help_index ;;
    -h|--help|help) wl_help_usage ;;
    *) wl_help_usage; return 2 ;;
  esac
}
