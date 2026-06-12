#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAP="$ROOT/vault-map.json"

echo
echo "Wonderland Vault Verification"
echo "root: $ROOT"
echo

python3 - "$ROOT" "$MAP" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
map_path = pathlib.Path(sys.argv[2])
failures = []

try:
    data = json.loads(map_path.read_text())
except Exception as exc:
    print(f"FAIL vault-map parse: {exc}")
    sys.exit(1)

if data.get("id") != "vault-map-v4":
    failures.append("vault-map id mismatch")

layers = data.get("layers")
if not isinstance(layers, list):
    failures.append("vault-map layers must be a list")
else:
    seen = set()
    for layer in layers:
        path = layer.get("path")
        layer_id = layer.get("id")

        if not path:
            failures.append(f"layer missing path: {layer}")
            continue

        if path in seen:
            failures.append(f"duplicate layer path: {path}")
        seen.add(path)

        target = root / path
        if not target.is_dir():
            failures.append(f"MISSING layer {path}")
        else:
            print(f"OK      {path}")

print()

if failures:
    for failure in failures:
        print(f"FAIL    {failure}")
    print()
    print("RESULT  FAIL")
    sys.exit(1)

print("RESULT  PASS")
PY
