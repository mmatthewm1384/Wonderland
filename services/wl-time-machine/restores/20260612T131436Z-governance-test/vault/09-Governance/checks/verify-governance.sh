#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo
echo "Wonderland Governance Verification"
echo "root: $ROOT"
echo

required=(
  "governance-registry.json"
  "docs/governance-overview.md"
  "docs/approval-standard.md"
  "docs/exception-standard.md"
  "docs/review-standard.md"
  "docs/authority-standard.md"
  "docs/compliance-standard.md"
  "registries/approval-registry.json"
  "registries/exception-registry.json"
  "registries/review-registry.json"
  "registries/authority-registry.json"
  "registries/compliance-registry.json"
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
  "$ROOT/governance-registry.json" \
  "$ROOT/registries/approval-registry.json" \
  "$ROOT/registries/exception-registry.json" \
  "$ROOT/registries/review-registry.json" \
  "$ROOT/registries/authority-registry.json" \
  "$ROOT/registries/compliance-registry.json"
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
