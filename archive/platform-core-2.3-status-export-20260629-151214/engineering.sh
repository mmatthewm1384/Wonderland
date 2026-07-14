#!/usr/bin/env bash
set -euo pipefail

wl_engineering_dispatch() {
  local ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
  local cmd="${1:-}"

  case "$cmd" in
    doctor)
      shift
      . "$ROOT/lib/doctor/cli.sh"
      wl_doctor_main "$@"
      ;;
    registry)
      shift
      . "$ROOT/lib/core/registry/command_registry_cli.sh"
      wl_registry_main "$@"
      ;;
    architecture)
      shift
      . "$ROOT/lib/architecture/cli.sh"
      wl_architecture_main "$@"
      ;;
    inventory)
      shift
      . "$ROOT/lib/inventory/cli.sh"
      wl_inventory_main "$@"
      ;;
    lint)
      shift
      . "$ROOT/lib/lint/cli.sh"
      wl_lint_main "$@"
      ;;
    migrate)
      shift
      . "$ROOT/lib/migrate/cli.sh"
      wl_migrate_main "$@"
      ;;
    refactor)
      shift
      . "$ROOT/lib/refactor/cli.sh"
      wl_refactor_main "$@"
      ;;
    report)
      shift
      . "$ROOT/lib/report/cli.sh"
      wl_report_main "$@"
      ;;
    fix)
      shift
      . "$ROOT/lib/fix/cli.sh"
      wl_fix_main "$@"
      ;;
    gate)
      shift
      . "$ROOT/lib/gate/cli.sh"
      wl_gate_main "$@"
      ;;
    *)
      return 127
      ;;
  esac
}
