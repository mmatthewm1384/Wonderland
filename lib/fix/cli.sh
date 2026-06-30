#!/usr/bin/env bash
set -euo pipefail

wl_fix_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_fix_plan() {
  local root out
  root="$(wl_fix_root)"
  out="$root/vault/05-Registry/fix/fix-plan.txt"
  mkdir -p "$(dirname "$out")"

  {
    echo "Wonderland Deterministic Fix Plan"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "Safe derived-artifact repairs"
    echo "-----------------------------"

    if [[ -f "$root/lib/core/registry/command_registry_cli.sh" ]]; then
      echo "SAFE registry: regenerate command registry and docs"
    else
      echo "FAIL registry: command registry CLI missing"
    fi

    if [[ -f "$root/lib/architecture/cli.sh" ]]; then
      echo "SAFE architecture: regenerate architecture report and graph"
    else
      echo "WARN architecture: tooling missing"
    fi

    if [[ -f "$root/lib/inventory/cli.sh" ]]; then
      echo "SAFE inventory: regenerate platform inventory"
    else
      echo "WARN inventory: tooling missing"
    fi

    if [[ -f "$root/lib/migrate/cli.sh" ]]; then
      echo "SAFE migrate: regenerate advisory migration plans"
    else
      echo "WARN migrate: tooling missing"
    fi

    if [[ -f "$root/lib/refactor/cli.sh" ]]; then
      echo "SAFE refactor: regenerate advisory refactor plan"
    else
      echo "WARN refactor: tooling missing"
    fi

    echo
    echo "Unsafe repairs intentionally excluded"
    echo "-------------------------------------"
    echo "UNSAFE source rewrites"
    echo "UNSAFE command deletion"
    echo "UNSAFE feature-command wrapper conversion"
    echo "UNSAFE release promotion"
    echo "UNSAFE governance mutation"
  } > "$out"

  cat "$out"
  echo
  echo "PASS fix plan $out"
}

wl_fix_apply_safe() {
  local root failed=0
  root="$(wl_fix_root)"

  echo "Wonderland Safe Fix Apply"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo

  if [[ -f "$root/lib/core/registry/command_registry_cli.sh" ]]; then
    . "$root/lib/core/registry/command_registry_cli.sh"
    wl_registry_main generate || failed=1
    wl_registry_main validate || failed=1
    wl_registry_main docs || failed=1
  fi

  if [[ -f "$root/lib/architecture/cli.sh" ]]; then
    . "$root/lib/architecture/cli.sh"
    wl_arch_report >/dev/null || failed=1
    wl_arch_graph || failed=1
  fi

  if [[ -f "$root/lib/inventory/cli.sh" ]]; then
    . "$root/lib/inventory/cli.sh"
    wl_inventory_generate >/dev/null || failed=1
  fi

  if [[ -f "$root/lib/migrate/cli.sh" ]]; then
    . "$root/lib/migrate/cli.sh"
    wl_migrate_main all >/dev/null || failed=1
  fi

  if [[ -f "$root/lib/refactor/cli.sh" ]]; then
    . "$root/lib/refactor/cli.sh"
    wl_refactor_main plan 200 >/dev/null || failed=1
  fi

  [[ "$failed" -eq 0 ]] && echo "RESULT PASS" || echo "RESULT FAIL"
  return "$failed"
}

wl_fix_usage() {
  cat <<'TXT'
Usage:
  wl fix plan
  wl fix apply --safe
TXT
}

wl_fix_main() {
  case "${1:-plan}" in
    plan) wl_fix_plan ;;
    apply)
      case "${2:-}" in
        --safe) wl_fix_apply_safe ;;
        *)
          echo "Refusing unsafe apply. Use: wl fix apply --safe"
          return 2
          ;;
      esac
      ;;
    -h|--help|help) wl_fix_usage ;;
    *) wl_fix_usage; return 2 ;;
  esac
}
