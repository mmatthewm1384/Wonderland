#!/usr/bin/env bash

wl_command_registry_main() {
  local action="${1:-refresh}"

  case "$action" in
    refresh)
      wl_command_registry_refresh
      ;;
    validate)
      wl_validate_json "$(wl_command_registry_file)"
      wl_validate_json_schema "$WL_ROOT/schemas/command-registry.schema.json" "$(wl_command_registry_file)"
      wl_result PASS
      ;;
    status)
      wl_command_registry_status
      ;;
    drift)
      wl_command_registry_drift
      ;;
    summary)
      wl_command_registry_summary
      ;;
    docs)
      wl_command_registry_docs
      ;;
    doctor)
      wl_command_registry_doctor
      ;;
    audit)
      wl_command_registry_audit
      ;;
    schema-paths)
      wl_command_registry_validate_schema_paths
      ;;
    schema-files)
      wl_command_registry_validate_schema_files
      ;;
    show)
      shift || true
      wl_command_registry_show "${1:-}"
      ;;
    path)
      wl_report "$(wl_command_registry_file)"
      wl_result PASS
      ;;
    *)
      wl_die "$WL_ERR_CONFIG" "unknown command registry action: $action"
      ;;
  esac
}
