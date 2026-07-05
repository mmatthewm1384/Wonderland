#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

wks_scan_docs() {
  local root out md_count adr_count knowledge_count
  root="$(wks_root)"
  out="$(wks_generated_dir)/documentation.md"

  md_count="$(find "$root" -type f -name "*.md" ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  adr_count="$(find "$root" -type f \( -name "ADR-*.md" -o -path "*/decisions/*.md" \) 2>/dev/null | wc -l | tr -d ' ')"
  knowledge_count="$(find "$root/knowledge" -type f \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | wc -l | tr -d ' ')"

  {
    echo "# Documentation Catalog"
    echo
    echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo
    echo "Markdown files: **$md_count**"
    echo "ADR / decision files: **$adr_count**"
    echo "Knowledge files: **$knowledge_count**"
    echo
    echo "## Knowledge Documents"
    find "$root/knowledge" -type f \( -name "*.md" -o -name "*.txt" \) ! -path "*/generated/*" ! -path "*/packages/*" 2>/dev/null \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
    echo
    echo "## ADR / Decision Documents"
    find "$root" -type f \( -name "ADR-*.md" -o -path "*/decisions/*.md" \) ! -path "*/.git/*" 2>/dev/null \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
  } > "$out"

  echo "$md_count"
}
