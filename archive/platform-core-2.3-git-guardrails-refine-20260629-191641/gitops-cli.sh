#!/usr/bin/env bash
set -euo pipefail

wl_git_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_git_status() {
  local root out
  root="$(wl_git_root)"
  out="$root/vault/05-Registry/git/latest-git-status.txt"
  mkdir -p "$(dirname "$out")"

  {
    echo "Wonderland Git Status"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    git status --short
    echo
    echo "Recent commits"
    echo "--------------"
    git log --oneline -5 || true
  } | tee "$out"
}

wl_git_checkpoint() {
  local root msg
  root="$(wl_git_root)"
  msg="${*:-certify Platform Core 2.3 engineering layer}"

  echo "Wonderland Git Checkpoint"
  echo "Message: $msg"
  echo

  "$root/bin/wl" certify platform-core 2.3

  git add \
    bin/wl \
    lib/core/dispatch \
    lib/core/registry \
    lib/doctor \
    lib/architecture \
    lib/inventory \
    lib/lint \
    lib/migrate \
    lib/refactor \
    lib/report \
    lib/fix \
    lib/gate \
    lib/status \
    lib/checkpoint \
    lib/rollback \
    lib/help \
    lib/certify \
    lib/gitops \
    vault/05-Registry \
    reports/verify.json

  echo
  echo "Staged files:"
  echo "-------------"
  git diff --cached --name-only

  echo
  echo "Review staged diff:"
  echo "  git diff --cached --stat"
  echo "  git diff --cached"
  echo
  echo "Commit when satisfied:"
  echo "  git commit -m \"$msg\""
  echo
  echo "RESULT PASS"
}

wl_git_usage() {
  cat <<'TXT'
Usage:
  wl git status
  wl git checkpoint [commit-message]

Notes:
  wl git checkpoint stages files only. It does not commit automatically.
TXT
}

wl_git_main() {
  case "${1:-status}" in
    status) wl_git_status ;;
    checkpoint)
      shift
      wl_git_checkpoint "$@"
      ;;
    -h|--help|help) wl_git_usage ;;
    *) wl_git_usage; return 2 ;;
  esac
}
