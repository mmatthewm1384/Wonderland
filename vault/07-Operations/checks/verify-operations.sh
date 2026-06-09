#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo
echo "Wonderland Operations Verification"
echo "root: $ROOT"
echo

required=(
  "operations-registry.json"
  "docs/operations-overview.md"
  "docs/audit-standard.md"
  "docs/snapshot-standard.md"
  "docs/drift-standard.md"
  "docs/lifecycle-standard.md"
  "docs/rollback-standard.md"
  "docs/restore-standard.md"
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

python3 -m json.tool "$ROOT/operations-registry.json" >/dev/null || fail=1

echo

if [[ "$fail" -eq 0 ]]; then
  echo "RESULT  PASS"
else
  echo "RESULT  FAIL"
  exit 1
fi
