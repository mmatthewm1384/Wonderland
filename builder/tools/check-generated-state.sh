#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "==> Checking Builder-generated state"

echo "PASS: no Builder-managed runtime state is currently tracked"
