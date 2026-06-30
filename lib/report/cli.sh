#!/usr/bin/env bash
set -euo pipefail

wl_report_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_report_platform() {
  local root out failed=0
  root="$(wl_report_root)"
  out="$root/vault/05-Registry/reports/platform-report.txt"
  mkdir -p "$(dirname "$out")"

  {
    echo "Wonderland Platform Engineering Report"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo

    echo "== Architecture =="
    if [[ -f "$root/lib/architecture/cli.sh" ]]; then
      . "$root/lib/architecture/cli.sh"
      wl_arch_report || failed=1
    else
      echo "WARN architecture tooling missing"
    fi

    echo
    echo "== Inventory =="
    if [[ -f "$root/lib/inventory/cli.sh" ]]; then
      . "$root/lib/inventory/cli.sh"
      wl_inventory_generate || failed=1
    else
      echo "WARN inventory tooling missing"
    fi

    echo
    echo "== Lint =="
    if [[ -f "$root/lib/lint/cli.sh" ]]; then
      . "$root/lib/lint/cli.sh"
      wl_lint_main all || failed=1
    else
      echo "WARN lint tooling missing"
    fi

    echo
    echo "== Doctor =="
    if [[ -f "$root/lib/doctor/cli.sh" ]]; then
      . "$root/lib/doctor/cli.sh"
      wl_doctor_main all || failed=1
    else
      echo "FAIL doctor tooling missing"
      failed=1
    fi

    echo
    [[ "$failed" -eq 0 ]] && echo "RESULT PASS" || echo "RESULT FAIL"
  } > "$out"

  cat "$out"
  echo
  echo "PASS platform report $out"
}

wl_report_usage() {
  cat <<'TXT'
Usage:
  wl report
  wl report platform
TXT
}

wl_report_main() {
  case "${1:-platform}" in
    platform) wl_report_platform ;;
    -h|--help|help) wl_report_usage ;;
    *) wl_report_usage; return 2 ;;
  esac
}
