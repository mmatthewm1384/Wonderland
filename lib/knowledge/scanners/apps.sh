#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

wks_scan_apps() {
  local root out app_count swift_count tauri_count
  root="$(wks_root)"
  out="$(wks_generated_dir)/applications.md"

  app_count=0
  [ -d "$root/apps" ] && app_count="$(find "$root/apps" -mindepth 1 -maxdepth 3 -type d 2>/dev/null | wc -l | tr -d ' ')"
  swift_count="$(find "$root" -path "*/Package.swift" 2>/dev/null | wc -l | tr -d ' ')"
  tauri_count="$(find "$root" -path "*/src-tauri/tauri.conf.json" -o -path "*/src-tauri/Tauri.toml" 2>/dev/null | wc -l | tr -d ' ')"

  {
    echo "# Application Catalog"
    echo
    echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo
    echo "Application directories: **$app_count**"
    echo "Swift packages: **$swift_count**"
    echo "Tauri apps: **$tauri_count**"
    echo
    echo "## App Paths"
    if [ -d "$root/apps" ]; then
      find "$root/apps" -mindepth 1 -maxdepth 3 -type d 2>/dev/null \
        | sed "s#^$root/##" \
        | sort \
        | awk '{print "- `" $0 "`"}'
    else
      echo "- apps directory not found"
    fi
    echo
    echo "## Swift Packages"
    find "$root" -path "*/Package.swift" 2>/dev/null \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
    echo
    echo "## Tauri Configs"
    find "$root" \( -path "*/src-tauri/tauri.conf.json" -o -path "*/src-tauri/Tauri.toml" \) 2>/dev/null \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
  } > "$out"

  echo "$app_count"
}
