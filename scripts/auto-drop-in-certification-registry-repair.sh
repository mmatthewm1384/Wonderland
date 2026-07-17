#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"
CERT="$ROOT/vault/08-Operations/certifications"

REGISTRY="$CERT/registry.json"

echo "== Wonderland Certification Registry Auto Drop-In =="

if [ ! -f "$REGISTRY" ]; then
    echo "Missing registry:"
    echo "$REGISTRY"
    exit 1
fi


python3 <<'PY'

from pathlib import Path
import json
import hashlib

root = Path("/Users/wonderland/Wonderland")

cert = (
    root
    / "vault"
    / "08-Operations"
    / "certifications"
)

registry_file = cert / "registry.json"


engine_files = {
    "repository":
        "engines/repository-certification.json",

    "architecture":
        "engines/architecture-certification.json",

    "builder":
        "engines/builder-certification.json",

    "governance":
        "engines/governance-certification.json",

    "mirror":
        "engines/mirror-certification.json",

    "academy":
        "engines/academy-certification.json",

    "runtime":
        "engines/runtime-certification.json",
}


registry = {
    "schema_version": 1,
    "active": {},
    "trust": {},
    "graph": {}
}


for name, rel in engine_files.items():

    artifact = cert / rel

    if artifact.exists():

        digest = hashlib.sha256(
            artifact.read_bytes()
        ).hexdigest()

        registry["active"][name] = {
            "artifact": str(
                artifact.relative_to(root)
            ),
            "certified": True,
            "digest": digest
        }

        print(
            f"REGISTERED {name}"
        )

    else:

        print(
            f"SKIPPED {name} (missing artifact)"
        )


registry_file.write_text(
    json.dumps(
        registry,
        indent=2,
        sort_keys=True
    ),
    encoding="utf-8"
)


print()
print("Registry repaired:")
print(registry_file)

PY


echo
echo "== Rebuild Certification Graph =="

./bin/wl-platform certify trust

echo
echo "== Verify =="

./bin/wl-platform verify
