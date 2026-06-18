#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
python3 "$DIR/scripts/agitate_lines.py"
cat "$DIR/exports/agitate-lines.txt"
