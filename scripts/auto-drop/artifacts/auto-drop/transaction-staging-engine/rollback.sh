#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

BACKUP=$(ls -t \
"$ROOT/scripts/auto-drop/lib/executor.sh.backup."* \
2>/dev/null | head -1)

if [[ -n "$BACKUP" ]]; then
    cp "$BACKUP" \
    "$ROOT/scripts/auto-drop/lib/executor.sh"
fi

echo "Transaction staging rollback complete"
