#!/usr/bin/env bash
set -euo pipefail

SPARK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Spark Path Integrity Check ==="
echo "Root: $SPARK_ROOT"
echo

TARGETS=(
    "$SPARK_ROOT/generated"
    "$SPARK_ROOT/profiles"
    "$SPARK_ROOT/registry.json"
)

PATTERNS=(
    "/Users/"
    "/Volumes/"
    "/private/"
    "/home/"
)

FOUND=0

for target in "${TARGETS[@]}"; do

    [[ -e "$target" ]] || continue

    echo "[SCAN] $target"

    for pattern in "${PATTERNS[@]}"; do

        while IFS= read -r line; do
            echo
            echo "[FOUND] $pattern"
            echo "$line"
            FOUND=1
        done < <(
            grep -R "$pattern" "$target" \
                --exclude-dir=.venv \
                --exclude=check-paths.sh \
                -n 2>/dev/null || true
        )

    done
done

echo

if [[ "$FOUND" -eq 1 ]]; then
    echo "[FAIL] Portable artifact path leakage detected"
    exit 1
fi

echo "[PASS] No portable artifact path leakage detected"
