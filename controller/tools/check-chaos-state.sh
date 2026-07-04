#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

AUDIT="runtime/chaos/scheduler-audit.jsonl"

case "${1:-check}" in
  check)
    echo "==> Checking Chaos runtime state"
    if [[ -f "$AUDIT" ]]; then
      echo "PASS: $AUDIT exists"
    else
      echo "WARN: $AUDIT missing"
    fi
    ;;

  restore)
    echo "Chaos runtime state is no longer Git-managed."
    ;;

  *)
    echo "Usage: $0 [check|restore]" >&2
    exit 2
    ;;
esac
