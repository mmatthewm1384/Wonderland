#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "==> Rebuilding Python virtual environment"
rm -rf .venv
python3 -m venv .venv

. .venv/bin/activate

python -m ensurepip --upgrade
python -m pip install --upgrade pip setuptools wheel
python -m pip install -e builder

echo "PASS: venv rebuilt"
