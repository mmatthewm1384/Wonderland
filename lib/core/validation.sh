#!/usr/bin/env bash

wl_validate_file() {
  local path="$1"
  [ -f "$path" ] || wl_die "$WL_ERR_VALIDATION" "missing file: $path"
  wl_pass "file exists: $path"
}

wl_validate_json() {
  local path="$1"
  wl_json_require
  jq empty "$path" >/dev/null || wl_die "$WL_ERR_VALIDATION" "invalid json: $path"
  wl_pass "valid json: $path"
}

wl_validate_runtime() {
  wl_validate_json "$WL_RUNTIME_DIR/context.json"
  wl_validate_json "$WL_RUNTIME_DIR/state.json"
  wl_validate_json "$WL_RUNTIME_DIR/health.json"
  wl_validate_json "$WL_RUNTIME_DIR/capabilities.json"
}

wl_validate_command_exists() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || wl_die "$WL_ERR_VALIDATION" "missing command: $cmd"
  wl_pass "command available: $cmd"
}

wl_validate_registry() {
  local registry="$WL_ROOT/config/commands/registry.json"
  wl_validate_json "$registry"
  wl_pass "command registry valid"
}

wl_verify_core() {
  wl_boot_environment
  wl_boot_storage
  wl_runtime_refresh
  wl_validate_runtime
  wl_validate_registry
  if declare -F wl_command_registry_drift >/dev/null 2>&1; then
    wl_command_registry_drift
  fi
  wl_release_validate
  wl_write_report "verify.json" status "PASS" root "$WL_ROOT"
  wl_result PASS
}

wl_validate_json_schema() {
  local schema="$1"
  local document="$2"

  wl_json_require
  wl_validate_file "$schema"
  wl_validate_file "$document"

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$schema" "$document" <<'PY'
import json
import sys

schema_path, document_path = sys.argv[1], sys.argv[2]

with open(schema_path, "r", encoding="utf-8") as f:
    schema = json.load(f)

with open(document_path, "r", encoding="utf-8") as f:
    document = json.load(f)

required_top = schema.get("required", [])
for key in required_top:
    if key not in document:
        raise SystemExit(f"missing required top-level key: {key}")

commands = document.get("commands")
if not isinstance(commands, dict):
    raise SystemExit("commands must be an object")

required_cmd = schema["properties"]["commands"]["additionalProperties"]["required"]

for name, meta in commands.items():
    if not isinstance(meta, dict):
        raise SystemExit(f"{name}: metadata must be an object")

    for key in required_cmd:
        if key not in meta:
            raise SystemExit(f"{name}: missing required key: {key}")

    if not isinstance(meta["command"], str):
        raise SystemExit(f"{name}: command must be string")
    if not isinstance(meta["phase"], str):
        raise SystemExit(f"{name}: phase must be string")
    if not isinstance(meta["category"], str):
        raise SystemExit(f"{name}: category must be string")
    if not isinstance(meta["path"], str):
        raise SystemExit(f"{name}: path must be string")
    if not isinstance(meta["requires"], list):
        raise SystemExit(f"{name}: requires must be array")
    if not isinstance(meta["provides"], list):
        raise SystemExit(f"{name}: provides must be array")
    if meta["json_schema"] is not None and not isinstance(meta["json_schema"], str):
        raise SystemExit(f"{name}: json_schema must be string or null")
PY
  else
    wl_die "$WL_ERR_VALIDATION" "python3 required for schema validation"
  fi

  wl_pass "schema valid: $document"
}
