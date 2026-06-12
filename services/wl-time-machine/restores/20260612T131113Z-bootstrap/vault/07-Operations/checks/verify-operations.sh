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
  "docs/runtime-drift-standard.md"
  "docs/restore-standard.md"
  "docs/recovery-drill-standard.md"
  "docs/rollback-standard.md"
  "docs/lifecycle-standard.md"
  "docs/promotion-standard.md"
  "docs/state-standard.md"
  "docs/report-standard.md"
  "promotion/promotion-registry.json"
  "restore/restore-registry.json"
  "rollback/rollback-registry.json"
  "lifecycle/lifecycle-registry.json"
  "state/state-registry.json"
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
  "$ROOT/operations-registry.json" \
  "$ROOT/promotion/promotion-registry.json" \
  "$ROOT/restore/restore-registry.json" \
  "$ROOT/rollback/rollback-registry.json" \
  "$ROOT/lifecycle/lifecycle-registry.json" \
  "$ROOT/state/state-registry.json"
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
