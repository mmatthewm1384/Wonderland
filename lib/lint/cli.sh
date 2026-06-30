#!/usr/bin/env bash
set -euo pipefail

wl_lint_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_lint_shell_structure() {
  local root failed=0 warned=0
  root="$(wl_lint_root)"

  echo "Wonderland Lint"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo

  find "$root/lib" -type f -name '*.sh' 2>/dev/null | sort | while read -r f; do
    rel="${f#$root/}"

    if ! head -5 "$f" | grep -q 'set -euo pipefail'; then
      echo "WARN missing strict mode: $rel"
    fi

    lines="$(wc -l < "$f" | tr -d ' ')"
    if [[ "$lines" -gt 250 ]]; then
      echo "WARN oversized module ${lines} lines: $rel"
    fi
  done

  if find "$root/lib" -type f -name '*.sh' 2>/dev/null \
    | xargs grep -H '^function ' 2>/dev/null \
    | awk '{print $2}' \
    | sort | uniq -d \
    | grep -q .; then
    echo "WARN duplicate function declarations detected"
    warned=1
  fi

  if [[ -x "$root/bin/wl" ]]; then
    echo "PASS bin/wl executable"
  else
    echo "FAIL bin/wl not executable"
    failed=1
  fi

  if [[ -f "$root/lib/wl-bootstrap.sh" ]]; then
    echo "PASS bootstrap present"
  else
    echo "FAIL bootstrap missing"
    failed=1
  fi

  if [[ "$failed" -eq 0 ]]; then
    echo "RESULT PASS"
  else
    echo "RESULT FAIL"
  fi

  return "$failed"
}

wl_lint_registry() {
  local root failed=0
  root="$(wl_lint_root)"

  if [[ -f "$root/lib/core/registry/command_registry_cli.sh" ]]; then
    . "$root/lib/core/registry/command_registry_cli.sh"
    wl_registry_main validate || failed=1
  else
    echo "FAIL registry cli missing"
    failed=1
  fi

  [[ "$failed" -eq 0 ]] && echo "RESULT PASS" || echo "RESULT FAIL"
  return "$failed"
}

wl_lint_usage() {
  cat <<'TXT'
Usage:
  wl lint
  wl lint shell
  wl lint registry
  wl lint all
TXT
}

wl_lint_main() {
  local target="${1:-all}"
  local failed=0

  case "$target" in
    shell) wl_lint_shell_structure ;;
    registry) wl_lint_registry ;;
    all)
      wl_lint_shell_structure || failed=1
      wl_lint_registry || failed=1
      return "$failed"
      ;;
    -h|--help|help) wl_lint_usage ;;
    *) wl_lint_usage; return 2 ;;
  esac
}
