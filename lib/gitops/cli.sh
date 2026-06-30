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
    vault/05-Registry/architecture/baselines/latest.tsv \
    vault/05-Registry/architecture/dependencies \
    vault/05-Registry/architecture/dependency.dot \
    vault/05-Registry/architecture/report.txt \
    vault/05-Registry/certifications/platform-core-2.3.json \
    vault/05-Registry/checkpoints/latest-platform-core.json \
    vault/05-Registry/command-registry.md \
    vault/05-Registry/command-registry.tsv \
    vault/05-Registry/docs/platform-engineering-commands.md \
    vault/05-Registry/exports/platform-core-2.3-certified-handoff.md \
    vault/05-Registry/exports/platform-handoff-latest.md \
    vault/05-Registry/fix/fix-plan.txt \
    vault/05-Registry/gates/latest-status.txt \
    vault/05-Registry/inventory/platform-inventory.txt \
    vault/05-Registry/migrate/registry-migration-plan.txt \
    vault/05-Registry/migrate/wrapper-migration-plan.txt \
    vault/05-Registry/refactor/module-split-plan.txt \
    vault/05-Registry/rollback/latest-rollback-plan.md \
    vault/05-Registry/status/latest-status.json \
    vault/05-Registry/status/latest-status.md \
    reports/verify.json

  git restore --staged \
    'vault/05-Registry/architecture/baselines/architecture-*.tsv' \
    vault/05-Registry/gates/latest-gate-check.txt \
    vault/05-Registry/gates/latest-gate-promote.txt \
    vault/05-Registry/git/latest-git-status.txt \
    vault/05-Registry/reports/platform-report.txt \
    2>/dev/null || true

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
