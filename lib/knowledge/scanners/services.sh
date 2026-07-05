#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

wks_scan_services() {
  local root out service_count plist_count compose_count
  root="$(wks_root)"
  out="$(wks_generated_dir)/services.md"

  service_count="$(find "$root" -type f \( -name "*.service" -o -name "*.timer" \) ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  plist_count="$(find "$root" -type f -name "*.plist" ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  compose_count="$(find "$root" -type f \( -name "compose.yml" -o -name "docker-compose.yml" -o -name "docker-compose.yaml" \) ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"

  {
    echo "# Service Catalog"
    echo
    echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo
    echo "systemd units: **$service_count**"
    echo "LaunchAgent / plist files: **$plist_count**"
    echo "Compose files: **$compose_count**"
    echo
    echo "## Service Files"
    find "$root" -type f \( -name "*.service" -o -name "*.timer" -o -name "*.plist" -o -name "compose.yml" -o -name "docker-compose.yml" -o -name "docker-compose.yaml" \) ! -path "*/.git/*" 2>/dev/null \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
  } > "$out"

  echo "$((service_count + plist_count + compose_count))"
}
