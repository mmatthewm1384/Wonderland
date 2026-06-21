#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

pandoc \
  "$ROOT/build/manuscript.md" \
  --toc \
  -s \
  -o "$ROOT/build/if-you-have-forgotten.html"

open -a Safari "$ROOT/build/if-you-have-forgotten.html"
