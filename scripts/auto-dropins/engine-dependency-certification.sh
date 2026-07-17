#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Dependency Certification =="

ROOT="${ROOT:-$HOME/Wonderland}"

cd "$ROOT"

REGISTRY_DIR="vault/05-Registry/engines"
CERT_DIR="vault/08-Operations/certifications"

mkdir -p "$REGISTRY_DIR"
mkdir -p "$CERT_DIR"

DEPENDENCIES="${REGISTRY_DIR}/dependencies.json"

if [ ! -f "$DEPENDENCIES" ]; then

cat > "$DEPENDENCIES" <<'JSON'
{
  "schema_version": 1,
  "dependencies": {
    "registry": [],
    "runtime": ["registry"],
    "builder": ["registry"],
    "academy": ["registry"],
    "governance": ["registry"],
    "mirror": ["runtime"]
  }
}
JSON

echo "Created dependencies.json"

else

echo "dependencies.json already exists"

fi

python3 <<'PY'
import json
from pathlib import Path
from datetime import datetime, timezone

root = Path.cwd()

registry_root = (
    root
    / "vault/05-Registry/engines"
)

capabilities_file = (
    registry_root
    / "capabilities.json"
)

dependencies_file = (
    registry_root
    / "dependencies.json"
)

engine_index_file = (
    registry_root
    / "engine-index.json"
)

errors = []

capabilities = json.loads(
    capabilities_file.read_text()
)

dependencies = json.loads(
    dependencies_file.read_text()
)

engine_index = json.loads(
    engine_index_file.read_text()
)

known_engines = {
    entry["name"]
    for entry in engine_index["engines"]
}

#
# validate owners
#

for capability, owner in (
    capabilities["owners"].items()
):

    if owner not in known_engines:

        errors.append(
            f"Unknown owner: {capability} -> {owner}"
        )

#
# validate dependencies
#

graph = dependencies["dependencies"]

for engine, deps in graph.items():

    if engine not in known_engines:

        errors.append(
            f"Unknown engine: {engine}"
        )

    for dep in deps:

        if dep not in known_engines:

            errors.append(
                f"Unknown dependency: {engine} -> {dep}"
            )

        if dep == engine:

            errors.append(
                f"Self dependency: {engine}"
            )

#
# cycle detection
#

visited = set()
active = set()

def dfs(node):

    if node in active:

        errors.append(
            f"Circular dependency: {node}"
        )

        return

    if node in visited:
        return

    visited.add(node)
    active.add(node)

    for child in graph.get(node, []):

        dfs(child)

    active.remove(node)

for node in graph:

    dfs(node)

result = (
    "PASS"
    if not errors
    else "FAIL"
)

artifact = {
    "schema_version": 1,
    "result": result,
    "engines": len(known_engines),
    "dependency_edges": sum(
        len(v)
        for v in graph.values()
    ),
    "errors": errors,
    "timestamp": (
        datetime.now(
            timezone.utc
        ).isoformat()
    ),
}

artifact_path = (
    root
    /
    "vault/08-Operations/certifications/engine-dependencies.json"
)

artifact_path.write_text(
    json.dumps(
        artifact,
        indent=2,
    )
)

print(
    json.dumps(
        artifact,
        indent=2,
    )
)

if errors:
    raise SystemExit(1)
PY

echo
echo "PASS dependency certification"
echo
echo "Artifact:"
echo "vault/08-Operations/certifications/engine-dependencies.json"
