#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "== Spark Document Factory v1 =="
echo "root: $WL_ROOT"

test -d "$WL_ROOT/sparks" || {
  echo "ERROR: sparks directory missing"
  exit 1
}

mkdir -p \
  "$WL_ROOT/sparks/factory/templates" \
  "$WL_ROOT/sparks/factory/schemas"

touch "$WL_ROOT/sparks/factory/.installed"

bash "$PKG_DIR/verify.sh"
