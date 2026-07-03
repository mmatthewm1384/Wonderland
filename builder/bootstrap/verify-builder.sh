#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "==> Verifying Builder V2"

bin/wl builder doctor
bin/wl builder status
bin/wl builder verify
builder/tools/check-generated-state.sh

echo "PASS: Builder V2 verification complete"
