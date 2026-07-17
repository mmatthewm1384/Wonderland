#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"
CERT="$ROOT/vault/08-Operations/certifications"

echo "== Wonderland Certification Artifact Resolver =="

python3 <<'PY'

from pathlib import Path
import json
import hashlib


root = Path("/Users/wonderland/Wonderland")
cert = root / "vault/08-Operations/certifications"

registry_file = cert / "registry.json"


targets = {
    "architecture": [
        "architecture-certification.json",
        "architecture.json"
    ],
    "builder": [
        "builder-certification.json",
        "builder.json"
    ],
    "governance": [
        "governance-certification.json",
        "governance.json"
    ],
    "mirror": [
        "mirror-certification.json",
        "mirror.json"
    ],
    "academy": [
        "academy-certification.json",
        "academy.json"
    ],
    "runtime": [
        "runtime-certification.json",
        "runtime.json"
    ],
}


registry = json.loads(
    registry_file.read_text()
)

registry["active"] = {}


for engine, names in targets.items():

    found = None

    for name in names:

        matches = list(
            cert.rglob(name)
        )

        if matches:
            found = matches[-1]
            break


    if found:

        digest = hashlib.sha256(
            found.read_bytes()
        ).hexdigest()

        registry["active"][engine] = {
            "artifact":
                str(found.relative_to(root)),
            "certified": True,
            "digest": digest
        }

        print(
            "REGISTERED",
            engine,
            found
        )

    else:
        print(
            "MISSING",
            engine
        )


registry_file.write_text(
    json.dumps(
        registry,
        indent=2,
        sort_keys=True
    )
)

print()
print("Updated:")
print(registry_file)

PY

./bin/wl-platform certify trust

./bin/wl-platform verify
