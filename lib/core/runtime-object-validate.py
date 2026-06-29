#!/usr/bin/env python3
import json
import sys
from pathlib import Path

SCHEMAS = {
    "context": {
        "schema": "wonderland.runtime.context.v1",
        "required": {
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
        },
    },
    "state": {
        "schema": "wonderland.runtime.state.v1",
        "required": {
            "schema": str,
            "runtime": str,
            "t7": str,
            "media": str,
            "torrent": str,
        },
    },
    "capabilities": {
        "schema": "wonderland.runtime.capabilities.v1",
        "required": {
            "schema": str,
            "internal_storage": bool,
            "external_storage": bool,
            "media": bool,
            "torrent": bool,
            "runtime": bool,
        },
    },
    "health": {
        "schema": "wonderland.runtime.health.v1",
        "required": {
            "schema": str,
            "pass": int,
            "warn": int,
            "fail": int,
            "corrupt": int,
            "result": str,
            "exit_code": int,
        },
    },
}

def detect_kind(path: Path) -> str:
    name = path.name
    if name == "context.json":
        return "context"
    if name == "state.json":
        return "state"
    if name == "capabilities.json":
        return "capabilities"
    if name == "health.json":
        return "health"
    raise ValueError(f"unknown runtime object: {path}")

def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: runtime-object-validate.py <json-file> [...]")
        return 1

    failed = False

    for arg in sys.argv[1:]:
        path = Path(arg)

        try:
            kind = detect_kind(path)
            spec = SCHEMAS[kind]
            data = json.loads(path.read_text())
        except Exception as exc:
            print(f"FAIL {path}: {exc}")
            failed = True
            continue

        errors = []

        if data.get("schema") != spec["schema"]:
            errors.append(f"schema mismatch: expected {spec['schema']} got {data.get('schema')}")

        for key, expected_type in spec["required"].items():
            if key not in data:
                errors.append(f"missing key: {key}")
            elif not isinstance(data[key], expected_type):
                errors.append(f"wrong type: {key}")

        if errors:
            for error in errors:
                print(f"FAIL {path}: {error}")
            failed = True
        else:
            print(f"PASS {kind} schema")

    return 1 if failed else 0

if __name__ == "__main__":
    raise SystemExit(main())
