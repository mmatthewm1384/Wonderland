#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

test -d "$WL_ROOT/sparks/factory/templates"
echo "PASS: factory templates"

test -d "$WL_ROOT/sparks/factory/schemas"
echo "PASS: factory schemas"

test -f "$WL_ROOT/sparks/factory/.installed"
echo "PASS: installation marker"

echo "PASS: Spark Document Factory v1 verification complete"
