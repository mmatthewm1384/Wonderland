#!/usr/bin/env bash
set -euo pipefail

echo "== Create Engine Index =="

ROOT="/Users/wonderland/Wonderland"

DIR="$ROOT/vault/05-Registry/engines"

mkdir -p "$DIR"


cat > "$DIR/engine-index.json" <<'JSON'
{
  "schema_version": 1,
  "engines": [
    {
      "name": "architecture",
      "module": "wlplatform.engines.architecture",
      "class": "ArchitectureEngine",
      "version": "1.1.0",
      "owner": "platform.architecture"
    },
    {
      "name": "builder",
      "module": "wlplatform.engines.builder",
      "class": "BuilderEngine",
      "version": "1.1.0",
      "owner": "platform.builder"
    },
    {
      "name": "governance",
      "module": "wlplatform.engines.governance",
      "class": "GovernanceEngine",
      "version": "1.1.0",
      "owner": "platform.governance"
    },
    {
      "name": "mirror",
      "module": "wlplatform.engines.mirror",
      "class": "MirrorEngine",
      "version": "1.1.0",
      "owner": "platform.mirror"
    },
    {
      "name": "academy",
      "module": "wlplatform.engines.academy",
      "class": "AcademyEngine",
      "version": "1.1.0",
      "owner": "platform.academy"
    },
    {
      "name": "registry",
      "module": "wlplatform.engines.registry",
      "class": "RegistryEngine",
      "version": "1.1.0",
      "owner": "platform.registry"
    }
  ]
}
JSON

echo "PASS"
