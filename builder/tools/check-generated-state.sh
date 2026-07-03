#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

GENERATED_PATHS=(
  builder/python/wlbuilder.egg-info/SOURCES.txt
  vault/08-Operations/state/latest.json
  vault/chaos/chaos-aether.json
  vault/chaos/scheduler-audit.jsonl
  vault/ephemeral-runs.log
)

restore() {
    echo "Restoring generated/runtime state..."
    git restore "${GENERATED_PATHS[@]}"
    echo "PASS"
}

check() {
    local dirty=0

    echo "==> Checking generated/runtime state"

    for path in "${GENERATED_PATHS[@]}"; do
        if git diff --quiet -- "$path"; then
            :
        else
            echo "DIRTY: $path"
            dirty=1
        fi
    done

    [[ $dirty -eq 0 ]]
}

case "${1:-check}" in
    check)
        if check; then
            echo "PASS: generated/runtime state is clean"
        else
            exit 1
        fi
        ;;
    restore)
        restore
        ;;
    *)
        echo "Usage: $0 [check|restore]"
        exit 2
        ;;
esac
