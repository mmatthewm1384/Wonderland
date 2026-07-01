#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
ACADEMY="$WL_ROOT/academy"
VERSION="${1:-1.0-alpha}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_DIR="$ACADEMY/08-certifications/records"
OUT="$OUT_DIR/wonderland-academy-${VERSION}-${STAMP}.md"

mkdir -p "$OUT_DIR"

{
  echo "# Wonderland Academy Certification Record"
  echo
  echo "Version: $VERSION"
  echo "Generated: $(date)"
  echo
  echo "## Certified Scope"
  echo
  echo "- Academy Constitution"
  echo "- Academy Canon"
  echo "- Wonderland Codex"
  echo "- Academy CLI"
  echo "- Module 1 Foundations scaffold"
  echo "- Content migration/lint framework"
  echo "- Quality, baseline, release, handoff, and summary workflows"
  echo
  echo "## Quality Gate"
  echo
  echo '```text'
  wl academy quality || true
  echo '```'
  echo
  echo "## Summary"
  echo
  echo '```text'
  wl academy summary || true
  echo '```'
} > "$OUT"

echo "PASS certification record written: $OUT"
