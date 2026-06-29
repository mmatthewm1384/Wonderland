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

  if declare -F wl_release_validate_manifest >/dev/null 2>&1; then
    wl_release_validate_manifest "$(wl_release_dir)/latest.json"
  fi

  if declare -F wl_release_validate_manifest >/dev/null 2>&1; then
    wl_release_validate_manifest "$(wl_release_dir)/latest.json"
  fi

  wl_pass "release validation passed"
}
