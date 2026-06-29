#!/usr/bin/env bash

wl_command_registry_drift() {
  local registry
  registry="$(wl_command_registry_file)"
  wl_validate_json "$registry"

  local actual registered
  actual="$(
    find "$WL_ROOT/bin" -maxdepth 1 -type f -name 'wl-*' ! -name '*.bak*' -exec basename {} \; |
      sort
  )"

  registered="$(
    jq -r '.commands | keys[]' "$registry" |
      sort
  )"

  if [ "$actual" != "$registered" ]; then
    wl_fail "command registry drift detected"

    comm -23 \
      <(printf '%s\n' "$actual") \
      <(printf '%s\n' "$registered") |
      sed 's/^/WARN missing_from_registry: /' >&2

    comm -13 \
      <(printf '%s\n' "$actual") \
      <(printf '%s\n' "$registered") |
      sed 's/^/WARN missing_from_bin: /' >&2

    wl_result FAIL
    return "$WL_ERR_VALIDATION"
  fi

  wl_pass "command registry matches bin"
  wl_result PASS
}

wl_command_registry_validate_schema_paths() {
  local registry
  registry="$(wl_command_registry_file)"
  wl_validate_json "$registry"

  local missing
  missing="$(
    jq -r '.commands | to_entries[] | select(.value.json_schema != null) | .value.json_schema' "$registry" |
      sort -u |
      while IFS= read -r schema; do
        [ -f "$WL_ROOT/$schema" ] || printf '%s\n' "$schema"
      done
  )"

  if [ -n "$missing" ]; then
    printf '%s\n' "$missing" | sed 's/^/FAIL missing schema path: /' >&2
    wl_result FAIL
    return "$WL_ERR_VALIDATION"
  fi

  wl_pass "registry schema paths valid"
  wl_result PASS
}

wl_command_registry_validate_schema_files() {
  local registry
  registry="$(wl_command_registry_file)"
  wl_validate_json "$registry"

  jq -r '.commands | to_entries[] | select(.value.json_schema != null) | .value.json_schema' "$registry" |
    sort -u |
    while IFS= read -r schema; do
      wl_validate_json "$WL_ROOT/$schema"
    done

  wl_pass "registry schema files valid"
  wl_result PASS
}
