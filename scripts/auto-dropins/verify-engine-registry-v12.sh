#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Registry v1.2 Verify =="

cd "$(dirname "$0")/../.."

export PYTHONPATH="$PWD/builder/python/wlplatform:$PYTHONPATH"


python3 - <<'PY'

from pathlib import Path

from wlplatform.engines import (
    ENGINE_CATALOG,
    graph,
    get_engine,
)


print("ENGINES")

for name in ENGINE_CATALOG:
    print(
        f" - {name}"
    )


print()
print("GRAPH")

for name,data in graph().items():
    print(
        name,
        "=>",
        data["depends_on"]
    )


engine = get_engine(
    "registry",
    Path.cwd()
)


result = engine.verify()

print()
print(result.to_dict())

assert result.status == "PASS"

print()
print("REGISTRY V1.2 PASS")

PY
