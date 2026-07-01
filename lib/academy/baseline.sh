#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
ACADEMY="$WL_ROOT/academy"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_DIR="$ACADEMY/09-progress/reviews/baselines"
OUT="$OUT_DIR/academy-baseline-$STAMP.md"

mkdir -p "$OUT_DIR"

{
  echo "# Wonderland Academy Baseline"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Root"
  echo
  "$WL_ROOT/bin/wl" root
  echo
  echo "## Academy Status"
  "$WL_ROOT/bin/wl" academy status || true
  echo
  echo "## Academy Inventory"
  "$WL_ROOT/bin/wl" academy inventory || true
  echo
  echo "## Academy Quality"
  "$WL_ROOT/bin/wl" academy quality || true
  echo
  echo "## Module 1"
  "$WL_ROOT/bin/wl" academy module1 || true
  echo
  echo "## Git Status"
  git -C "$WL_ROOT" status --short
} > "$OUT"

echo "PASS academy baseline written: $OUT"
