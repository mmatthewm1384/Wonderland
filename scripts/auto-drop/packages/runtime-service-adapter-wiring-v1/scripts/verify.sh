#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

test -f "$ROOT/manifest.json"
test -f "$ROOT/artifacts/metadata.yaml"
test -f "$ROOT/certification/schema.json"

test -x "$ROOT/scripts/install.sh"
test -x "$ROOT/scripts/verify.sh"
test -x "$ROOT/scripts/rollback.sh"

echo "CERTIFIED"
