#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
ACADEMY="$WL_ROOT/academy"
VERSION="${1:-0.3.0}"
STAMP="$(date +%Y%m%d-%H%M%S)"
RELEASE_DIR="$ACADEMY/09-progress/reviews/releases"
RELEASE_FILE="$RELEASE_DIR/academy-core-${VERSION}-${STAMP}.md"

mkdir -p "$RELEASE_DIR"

{
  echo "# Wonderland Academy Core ${VERSION}"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Certification"
  echo
  wl academy quality
  echo
  echo "## Inventory"
  echo
  wl academy inventory
  echo
  echo "## Git Status"
  echo
  git status --short
} > "$RELEASE_FILE"

echo "PASS Academy release generated: $RELEASE_FILE"
