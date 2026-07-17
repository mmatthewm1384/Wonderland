#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Registry v1.5-v1.7 Upgrade =="

ROOT="${ROOT:-$HOME/Wonderland}"

cd "$ROOT"

ENGINE_ROOT="vault/05-Registry/engines"

mkdir -p "$ENGINE_ROOT"
mkdir -p vault/08-Operations/state
mkdir -p vault/08-Operations/certifications

create_engine() {

    local name="$1"
    local module="$2"
    local class="$3"

    cat > "${ENGINE_ROOT}/${name}.json" <<EOF
{
  "name": "${name}",
  "module": "${module}",
  "class": "${class}",
  "version": "1.0.0"
}
EOF
}

create_engine \
    architecture \
    wlplatform.engines.architecture \
    ArchitectureEngine

create_engine \
    builder \
    wlplatform.engines.builder \
    BuilderEngine

create_engine \
    governance \
    wlplatform.engines.governance \
    GovernanceEngine

create_engine \
    mirror \
    wlplatform.engines.mirror \
    MirrorEngine

create_engine \
    academy \
    wlplatform.engines.academy \
    AcademyEngine

create_engine \
    registry \
    wlplatform.engines.registry \
    RegistryEngine

create_engine \
    runtime \
    wlplatform.engines.runtime \
    RuntimeEngine

echo "Engine descriptors created"

python3 <<'PY'
import json
from pathlib import Path

root = Path.cwd()

engine_root = (
    root
    / "vault/05-Registry/engines"
)

index = []

for path in sorted(
    engine_root.glob("*.json")
):

    if path.name in {
        "capabilities.json",
        "engine-index.json",
    }:
        continue

    payload = json.loads(
        path.read_text()
    )

    index.append(payload)

(engine_root / "engine-index.json").write_text(
    json.dumps(
        {
            "schema_version": 1,
            "engines": index,
        },
        indent=2,
    )
)

print(
    f"Indexed {len(index)} engines"
)
PY

python3 <<'PY'
import json
from pathlib import Path

root = Path.cwd()

capabilities = (
    root
    / "vault/05-Registry/engines/capabilities.json"
)

payload = json.loads(
    capabilities.read_text()
)

owners = payload["owners"]

nodes = []
edges = []

engines = set()

for capability, owner in owners.items():

    engines.add(owner)

    nodes.append(
        {
            "id": capability,
            "type": "capability",
        }
    )

    edges.append(
        {
            "from": capability,
            "to": owner,
            "type": "owned_by",
        }
    )

for engine in sorted(engines):

    nodes.append(
        {
            "id": engine,
            "type": "engine",
        }
    )

graph = {
    "schema_version": 1,
    "nodes": nodes,
    "edges": edges,
}

(root /
 "vault/08-Operations/state/capability-graph.json"
).write_text(
    json.dumps(
        graph,
        indent=2,
    )
)

(root /
 "vault/08-Operations/state/capability-ownership.json"
).write_text(
    json.dumps(
        {
            "schema_version": 1,
            "owners": owners,
        },
        indent=2,
    )
)

print(
    f"Exported {len(owners)} capabilities"
)
PY

python3 <<'PY'
import json
from pathlib import Path
from datetime import datetime, timezone

root = Path.cwd()

capabilities = (
    root
    / "vault/05-Registry/engines/capabilities.json"
)

payload = json.loads(
    capabilities.read_text()
)

owners = payload["owners"]

errors = []

for capability, owner in owners.items():

    if "." not in capability:
        errors.append(
            f"Invalid capability: {capability}"
        )

    if not owner:
        errors.append(
            f"No owner: {capability}"
        )

result = (
    "PASS"
    if not errors
    else "FAIL"
)

artifact = {
    "result": result,
    "capabilities": len(owners),
    "errors": errors,
    "timestamp": (
        datetime.now(
            timezone.utc
        ).isoformat()
    ),
}

(
 root
 /
 "vault/08-Operations/certifications/capability-ownership.json"
).write_text(
    json.dumps(
        artifact,
        indent=2,
    )
)

print(
    f"Certification: {result}"
)

if errors:
    raise SystemExit(1)
PY

echo
echo "Verification:"
echo "cat vault/05-Registry/engines/engine-index.json"
echo "cat vault/08-Operations/state/capability-graph.json"
echo "cat vault/08-Operations/certifications/capability-ownership.json"

echo
echo "DONE"
