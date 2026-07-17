#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "== Wonderland Engine Ownership Graph v1.2 =="

TARGET="$ROOT/vault/05-Registry/engines/engine-graph.json"

mkdir -p "$(dirname "$TARGET")"

cat > "$TARGET" <<'EOF'
{
  "schema_version": "1.2",
  "graph_type": "engine-capability-ownership",

  "nodes": [
    {
      "id": "architecture",
      "type": "engine",
      "owner": "wlarchitecture"
    },
    {
      "id": "builder",
      "type": "engine",
      "owner": "wlbuilder"
    },
    {
      "id": "governance",
      "type": "engine",
      "owner": "wlgovernance"
    },
    {
      "id": "registry",
      "type": "engine",
      "owner": "wlplatform"
    },
    {
      "id": "mirror",
      "type": "engine",
      "owner": "wlmirror"
    },
    {
      "id": "academy",
      "type": "engine",
      "owner": "wlacademy"
    }
  ],

  "edges": [
    {
      "from": "registry",
      "to": "architecture",
      "relationship": "discovers"
    },
    {
      "from": "registry",
      "to": "builder",
      "relationship": "discovers"
    },
    {
      "from": "registry",
      "to": "governance",
      "relationship": "discovers"
    },
    {
      "from": "registry",
      "to": "mirror",
      "relationship": "discovers"
    },
    {
      "from": "registry",
      "to": "academy",
      "relationship": "discovers"
    }
  ]
}
EOF


python3 -m json.tool \
"$TARGET" >/dev/null


echo "Engine ownership graph created"
echo "PASS"
