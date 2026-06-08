#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
  "README.md"
  "governance/operator-authority.md"
  "governance/system-principles.md"
  "identity/wonderland-identity.md"
  "topology/root-map.md"
  "operations/command-authority.md"
  "recovery/recovery-policy.md"
  "manifests/seed-vault-manifest.md"
  "schemas/core-document.schema.json"
)

fail=0

for file in "${required[@]}"; do
  if [[ ! -f "$ROOT/$file" ]]; then
    echo "MISSING: $file"
    fail=1
  else
    echo "OK: $file"
  fi
done

if [[ "$fail" -ne 0 ]]; then
  echo "Core vault verification failed."
  exit 1
fi

echo "Core vault verification passed."
