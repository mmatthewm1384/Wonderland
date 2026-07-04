#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

CONTROLLER_STATE=(
  "vault/08-Operations/state/latest.json"
  "vault/chaos/chaos-aether.json"
  "vault/chaos/scheduler-audit.jsonl"
  "vault/ephemeral-runs.log"
)

action="${1:-check}"

case "$action" in
  check)
    echo "==> Checking Controller runtime state"
    dirty=0

    for path in "${CONTROLLER_STATE[@]}"; do
      if git status --short -- "$path" | grep -q .; then
        echo "DIRTY: $path"
        dirty=1
      fi
    done

    if [[ "$dirty" -ne 0 ]]; then
      echo
      echo "Restore with:"
      echo "controller/tools/check-controller-state.sh restore"
      exit 1
    fi

    echo "PASS: Controller runtime state is clean"
    ;;

  restore)
    echo "==> Restoring Controller runtime state"
    git restore "${CONTROLLER_STATE[@]}"
    echo "PASS: Controller runtime state restored"
    ;;

  *)
    echo "Usage: $0 [check|restore]" >&2
    exit 2
    ;;
esac
