#!/usr/bin/env bash

: "${WL_HOME:=$HOME/Wonderland}"
: "${WL_RUNTIME_DIR:=$WL_HOME/runtime}"
: "${WL_CONTEXT_FILE:=$WL_RUNTIME_DIR/context.json}"

wl_context_init() {
  mkdir -p "$WL_RUNTIME_DIR"

  python3 - <<PY
import json, os
from pathlib import Path

home = Path(os.environ.get("WL_HOME", str(Path.home() / "Wonderland")))

ctx = {
    "schema": "wonderland.runtime.context.v1",
    "version": os.environ.get("WL_VERSION", "0.0.0"),
    "build": os.environ.get("WL_BUILD", "unknown"),
    "channel": os.environ.get("WL_CHANNEL", "local"),
    "root": str(home),
    "mode": os.environ.get("WL_MODE", "light"),
    "profile": os.environ.get("WL_PROFILE", "internal-light"),
    "runtime_instance": os.environ.get("WL_RUNTIME_INSTANCE", "wonderland-rootless"),
    "report_dir": os.environ.get(
        "WL_REPORT_DIR",
        str(home / "vault/08-Operations/reports")
    ),
    "runtime_dir": os.environ.get("WL_RUNTIME_DIR", str(home / "runtime")),
    "config_dir": os.environ.get("WL_CONFIG_DIR", str(home / "config")),
    "lib_dir": os.environ.get("WL_LIB_DIR", str(home / "lib")),
    "bin_dir": os.environ.get("WL_BIN_DIR", str(home / "bin")),
    "t7_path": os.environ.get("WL_T7_PATH", "/Volumes/T7_Wonderland"),
}

out = Path(os.environ.get("WL_CONTEXT_FILE", str(home / "runtime/context.json")))
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(ctx, indent=2) + "\\n")
PY
}

wl_context_get() {
  local key="${1:-}"

  if [[ -z "$key" ]]; then
    echo "FAIL context key required"
    return 1
  fi

  if [[ ! -f "$WL_CONTEXT_FILE" ]]; then
    wl_context_init
  fi

  python3 - "$WL_CONTEXT_FILE" "$key" <<'PY'
import json, sys

path, key = sys.argv[1], sys.argv[2]
data = json.load(open(path))

value = data
for part in key.split("."):
    if isinstance(value, dict) and part in value:
        value = value[part]
    else:
        sys.exit(1)

if isinstance(value, (dict, list)):
    print(json.dumps(value))
else:
    print(value)
PY
}

wl_context_dump() {
  [[ -f "$WL_CONTEXT_FILE" ]] || wl_context_init
  cat "$WL_CONTEXT_FILE"
}

wl_context_refresh() {
  wl_context_init
}
