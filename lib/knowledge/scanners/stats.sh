#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

wks_scan_stats() {
  local root out files dirs shell python swift ts md
  root="$(wks_root)"
  out="$(wks_generated_dir)/statistics.md"

  files="$(find "$root" -type f ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  dirs="$(find "$root" -type d ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  shell="$(find "$root" -type f \( -name "*.sh" -o -path "*/bin/*" \) ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  python="$(find "$root" -type f -name "*.py" ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  swift="$(find "$root" -type f -name "*.swift" ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  ts="$(find "$root" -type f \( -name "*.ts" -o -name "*.tsx" \) ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  md="$(find "$root" -type f -name "*.md" ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"

  {
    echo "# Repository Statistics"
    echo
    echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo
    echo "| Metric | Count |"
    echo "|---|---:|"
    echo "| Files | $files |"
    echo "| Directories | $dirs |"
    echo "| Shell / command files | $shell |"
    echo "| Python files | $python |"
    echo "| Swift files | $swift |"
    echo "| TypeScript files | $ts |"
    echo "| Markdown files | $md |"
  } > "$out"

  echo "$files"
}
