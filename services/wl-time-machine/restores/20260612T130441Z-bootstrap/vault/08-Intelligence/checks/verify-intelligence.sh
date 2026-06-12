#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo
echo "Wonderland Intelligence Verification"
echo "root: $ROOT"
echo

required=(
  "intelligence-registry.json"
  "docs/intelligence-overview.md"
  "docs/intent-model.md"
  "docs/plan-model.md"
  "docs/execution-model.md"
  "docs/memory-model.md"
  "docs/knowledge-model.md"
  "docs/decision-model.md"
  "registries/memory-registry.json"
  "registries/knowledge-registry.json"
  "registries/decision-registry.json"
)

fail=0

for file in "${required[@]}"; do
  if [[ -f "$ROOT/$file" ]]; then
    echo "OK      $file"
  else
    echo "MISSING $file"
    fail=1
  fi
done

for json in \
  "$ROOT/intelligence-registry.json" \
  "$ROOT/registries/memory-registry.json" \
  "$ROOT/registries/knowledge-registry.json" \
  "$ROOT/registries/decision-registry.json"
do
  python3 -m json.tool "$json" >/dev/null || fail=1
done

echo

if [[ "$fail" -eq 0 ]]; then
  echo "RESULT  PASS"
else
  echo "RESULT  FAIL"
  exit 1
fi
