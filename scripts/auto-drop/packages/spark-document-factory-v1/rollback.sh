#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

rm -f "$WL_ROOT/sparks/factory/.installed"

echo "PASS: Spark Document Factory v1 rollback"
