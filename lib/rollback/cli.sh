#!/usr/bin/env bash
set -euo pipefail

wl_rollback_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_rollback_plan() {
  local root out latest cert
  root="$(wl_rollback_root)"
  latest="$root/vault/05-Registry/checkpoints/latest-platform-core.json"
  cert="$root/vault/05-Registry/certifications/platform-core-2.3.json"
  out="$root/vault/05-Registry/rollback/latest-rollback-plan.md"

  mkdir -p "$(dirname "$out")"

  {
    echo "# Wonderland Rollback Plan"
    echo
    echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "## Source of Truth"
    echo
    echo "- Latest checkpoint: ${latest#$root/}"
    echo "- Certification: ${cert#$root/}"
    echo
    echo "## Validation"
    echo
    echo '```bash'
    echo "wl checkpoint validate"
    echo "wl status"
    echo "wl doctor all"
    echo "wl verify"
    echo '```'
    echo
    echo "## Manual Recovery Strategy"
    echo
    echo "1. Inspect the latest certified checkpoint."
    echo "2. Compare current status with the checkpoint status artifacts."
    echo "3. Restore from Git first if source files changed."
    echo "4. Regenerate derived artifacts with safe fix."
    echo "5. Re-run doctor and verify."
    echo
    echo "## Safe Recovery Commands"
    echo
    echo '```bash'
    echo "git status --short"
    echo "wl checkpoint latest"
    echo "wl checkpoint validate"
    echo "wl fix apply --safe"
    echo "wl doctor all"
    echo "wl verify"
    echo '```'
    echo
    echo "## Explicitly Not Automated"
    echo
    echo "- No source overwrite"
    echo "- No release promotion"
    echo "- No deletion"
    echo "- No governance mutation"
    echo "- No external disk assumptions"
  } > "$out"

  cat "$out"
  echo
  echo "PASS rollback plan $out"
}

wl_rollback_usage() {
  cat <<'TXT'
Usage:
  wl rollback plan
TXT
}

wl_rollback_main() {
  case "${1:-plan}" in
    plan) wl_rollback_plan ;;
    -h|--help|help) wl_rollback_usage ;;
    *) wl_rollback_usage; return 2 ;;
  esac
}
