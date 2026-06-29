#!/usr/bin/env bash

wl_release_validate() {
  wl_validate_runtime

  if declare -F wl_command_registry_drift >/dev/null 2>&1; then
    wl_command_registry_drift
  fi

  if declare -F wl_command_registry_validate_schema_paths >/dev/null 2>&1; then
    wl_command_registry_validate_schema_paths
  fi

  if declare -F wl_command_registry_validate_schema_files >/dev/null 2>&1; then
    wl_command_registry_validate_schema_files
  fi

  wl_pass "release validation passed"
}
