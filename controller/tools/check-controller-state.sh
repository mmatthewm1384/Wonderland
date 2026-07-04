#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

STATE="runtime/controller/latest.json"

case "${1:-check}" in
  check)
    echo "==> Checking Controller runtime state"
    if [[ -f "$STATE" ]]; then
      echo "PASS: $STATE exists"
    else
      echo "WARN: $STATE missing"
    fi
    ;;

  restore)
    echo "Controller runtime state is no longer Git-managed."
    ;;

  *)
    echo "Usage: $0 [check|restore]" >&2
    exit 2
    ;;
esac
