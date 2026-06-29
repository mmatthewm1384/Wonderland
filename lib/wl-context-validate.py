#!/usr/bin/env python3
import json
import sys
from pathlib import Path

required = {
    "schema": str,
    "version": str,
    "build": str,
    "channel": str,
    "root": str,
    "mode": str,
    "profile": str,
    "runtime_instance": str,
    "report_dir": str,
    "runtime_dir": str,
    "config_dir": str,
    "lib_dir": str,
    "bin_dir": str,
    "t7_path": str,
}

path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / "Wonderland/runtime/context.json"

try:
    data = json.loads(path.read_text())
except Exception as exc:
    print(f"FAIL invalid json: {path}: {exc}")
    sys.exit(1)

errors = []

for key, expected_type in required.items():
    if key not in data:
        errors.append(f"missing key: {key}")
    elif not isinstance(data[key], expected_type):
        errors.append(f"wrong type: {key}")

if data.get("schema") != "wonderland.runtime.context.v1":
    errors.append("schema mismatch")

for path_key in ["root", "runtime_dir", "config_dir", "lib_dir", "bin_dir"]:
    value = Path(data.get(path_key, ""))
    if not value.exists():
        errors.append(f"path missing: {path_key}={value}")

if errors:
    for error in errors:
        print(f"FAIL {error}")
    sys.exit(1)

print("PASS context schema")
