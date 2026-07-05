#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

wks_scan_graph() {
  local root out
  root="$(wks_root)"
  out="$(wks_generated_dir)/knowledge-graph.md"

  {
    echo "# Knowledge Graph"
    echo
    echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo
    echo '```text'
    echo "Wonderland"
    [ -d "$root/bin" ] && echo "├── Commands"
    [ -d "$root/lib" ] && echo "├── Libraries"
    [ -d "$root/apps" ] && echo "├── Applications"
    [ -d "$root/builder" ] && echo "├── Builder"
    [ -d "$root/controller" ] && echo "├── Controller"
    [ -d "$root/config" ] && echo "├── Configuration"
    [ -d "$root/docs" ] && echo "├── Documentation"
    [ -d "$root/vault" ] && echo "├── Vault"
    [ -d "$root/knowledge" ] && echo "└── Knowledge"
    echo '```'
    echo
    echo "## Primary Generated Catalogs"
    echo
    echo "- [Command Catalog](commands.md)"
    echo "- [Application Catalog](applications.md)"
    echo "- [Documentation Catalog](documentation.md)"
    echo "- [Service Catalog](services.md)"
    echo "- [Repository Statistics](statistics.md)"
  } > "$out"

  echo "1"
}
