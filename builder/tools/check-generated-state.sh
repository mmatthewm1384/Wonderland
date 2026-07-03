#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

GENERATED_PATHS=(
  "builder/python/wlbuilder.egg-info/SOURCES.txt"
  "vault/08-Operations/state/latest.json"
  "vault/chaos/chaos-aether.json"
  "vault/chaos/scheduler-audit.jsonl"
  "vault/ephemeral-runs.log"
)

dirty=0

echo "==> Checking generated/runtime state"

for path in "${GENERATED_PATHS[@]}"; do
  if git status --short -- "$path" | grep -q .; then
    echo "DIRTY: $path"
    dirty=1
  fi
done

if [[ "$dirty" -ne 0 ]]; then
  echo
  echo "Generated/runtime files are dirty."
  echo "Restore with:"
  echo
  echo "git restore \\"
  for path in "${GENERATED_PATHS[@]}"; do
    echo "  $path \\"
  done
  echo
  exit 1
fi

echo "PASS: generated/runtime state is clean"
