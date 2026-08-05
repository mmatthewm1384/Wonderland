#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Checking runtime contract..."

checks=(
"$ROOT/certification/schema.json"
"$ROOT/certification/runtime-contract.json"
"$ROOT/artifacts/runtime-contract-certification-report.json"
)

for file in "${checks[@]}"; do
    if [ ! -f "$file" ]; then
        echo "FAIL missing: $file"
        exit 1
    fi
done

echo "Runtime contract verification PASS"
