#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

mkdir -p "$ROOT/build"

find "$ROOT/manuscript" \
  -name '*.md' \
  | sort \
  | xargs cat \
  > "$ROOT/build/manuscript.md"

echo "[ok] manuscript assembled"
echo "$ROOT/build/manuscript.md"
