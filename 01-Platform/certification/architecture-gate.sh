#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$WL_ROOT"

python3 01-Platform/architecture/engine.py gate --root "$WL_ROOT"
