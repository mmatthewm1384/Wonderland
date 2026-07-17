#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

CERT_DIR="$ROOT/vault/08-Operations/certifications"
NORMALIZED="$CERT_DIR/normalized"
REGISTRY="$CERT_DIR/registry.json"

echo "== Wonderland Certification Contract Migration =="

cd "$ROOT"

echo
echo "== Backup Registry =="

cp "$REGISTRY" \
"$REGISTRY.backup.$(date +%Y%m%dT%H%M%S)"

mkdir -p "$NORMALIZED"


echo
echo "== Normalize Certification Artifacts =="

python3 <<'PY'

from pathlib import Path
import json
import hashlib
from datetime import datetime, timezone


ROOT = Path("/Users/wonderland/Wonderland")

CERT = ROOT / "vault/08-Operations/certifications"

OUT = CERT / "normalized"

ENGINES = CERT / "engines"


def digest(path):
    h = hashlib.sha256()
    h.update(path.read_bytes())
    return h.hexdigest()


sources = {
    "architecture":
        ENGINES / "architecture-certification.json",

    "builder":
        ENGINES / "builder-certification.json",

    "governance":
        ENGINES / "governance-certified-20260711T193020Z-certification.json",

    "mirror":
        ENGINES / "mirror-certified-20260706-150241-certification.json",

    "academy":
        ENGINES / "academy-certify-certification.json",

    "runtime":
        sorted(
            ENGINES.glob(
                "runtime-engine-certified-*-certification.json"
            )
        )[-1],
}


registry = {
    "schema_version": 1,
    "active": {},
    "trust": {},
    "graph": {}
}


for engine, source in sources.items():

    if not source.exists():
        print("SKIP", engine, source)
        continue


    raw = json.loads(source.read_text())


    certified = (
        raw.get("certified") is True
        or raw.get("status") == "PASS"
        or raw.get("result") == "PASS"
        or raw.get("result") == "CERTIFIED"
    )


    normalized = {
        "schema_version": 1,
        "engine": engine,
        "certified": certified,
        "status": "PASS" if certified else "FAIL",
        "digest": digest(source),
        "source": str(source),
        "generated": datetime.now(
            timezone.utc
        ).isoformat()
    }


    out = OUT / f"{engine}.json"

    out.write_text(
        json.dumps(
            normalized,
            indent=2
        )
    )


    registry["active"][engine] = {
        "artifact": str(
            out.relative_to(ROOT)
        ),
        "certified": certified,
        "digest": normalized["digest"]
    }


    print(
        "NORMALIZED",
        engine,
        "PASS" if certified else "FAIL"
    )


(CERT / "registry.json").write_text(
    json.dumps(
        registry,
        indent=2
    )
)


print()
print("Registry updated:")
print(CERT / "registry.json")

PY


echo
echo "== Rebuild Certification Trust =="

./bin/wl-platform certify trust


echo
echo "== Verify Platform =="

./bin/wl-platform verify
