#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
ACADEMY="$WL_ROOT/academy"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_DIR="$ACADEMY/09-progress/reviews/handoffs"
OUT="$OUT_DIR/academy-handoff-$STAMP.md"

mkdir -p "$OUT_DIR"

{
  echo "# Wonderland Academy Handoff"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Status"
  echo
  echo "Wonderland Academy has been established as a first-class Wonderland subsystem."
  echo
  echo "Current major artifacts:"
  echo
  echo "- academy/CONSTITUTION.md"
  echo "- academy/CANON.md"
  echo "- academy/CODEX.md"
  echo "- academy/01-curriculum/year-1/module-01-foundations/README.md"
  echo "- academy/05-reference/glossary/FOUNDATIONS.md"
  echo "- academy/05-reference/cheat-sheets/FOUNDATIONS.md"
  echo "- academy/06-diagrams/computer-science/FOUNDATIONS.md"
  echo
  echo "## CLI Commands"
  echo
  echo '```text'
  wl academy help || true
  echo '```'
  echo
  echo "## Quality"
  echo
  echo '```text'
  wl academy quality || true
  echo '```'
  echo
  echo "## Module 1"
  echo
  echo '```text'
  wl academy module1 || true
  echo '```'
  echo
  echo "## Inventory"
  echo
  echo '```text'
  wl academy inventory || true
  echo '```'
  echo
  echo "## Git Status"
  echo
  echo '```text'
  git -C "$WL_ROOT" status --short
  echo '```'
  echo
  echo "## Recommended Next Steps"
  echo
  echo "1. Resolve any remaining `wl academy quality` failures."
  echo "2. Continue authoring Day 001 to publication quality."
  echo "3. Expand Module 1 lessons from scaffold to complete chapters."
  echo "4. Build Wonderland Labs as first-class practice artifacts."
  echo "5. Begin planning the future `wl-academy` SwiftUI app after Module 1 stabilizes."
} > "$OUT"

echo "PASS academy handoff written: $OUT"
