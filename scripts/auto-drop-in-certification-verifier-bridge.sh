#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"
CERT="$ROOT/vault/08-Operations/certifications"
ENGINES="$CERT/engines"

echo "== Wonderland Certification Verifier Bridge =="

mkdir -p "$ENGINES"

backup="$CERT/registry.json.bridge-backup"

cp "$CERT/registry.json" "$backup"

echo
echo "Backup:"
echo "$backup"


python3 <<'PY'

from pathlib import Path
import json
import shutil
import hashlib

ROOT = Path("/Users/wonderland/Wonderland")
CERT = ROOT / "vault/08-Operations/certifications"
ENGINES = CERT / "engines"


mapping = {
    "architecture": CERT / "architecture/active/architecture-certification.json",
    "builder": CERT / "builder/20260711T215708Z/builder-certification.json",
    "governance": CERT / "governance/20260711T220317Z/governance-certification.json",
    "mirror": CERT / "mirror/20260712T023823Z/mirror-certification.json",
    "academy": CERT / "academy/20260712T024712Z/academy-certification.json",
    "runtime": CERT / "active/runtime-certification.json",
}


def digest(path):
    return hashlib.sha256(
        path.read_bytes()
    ).hexdigest()


for engine, source in mapping.items():

    if not source.exists():
        print("MISSING", engine, source)
        continue

    target = ENGINES / f"{engine}-certification.json"

    shutil.copy2(source, target)

    data=json.loads(target.read_text())

    # normalize contract
    normalized = {
        "schema_version":1,
        "engine":engine,
        "status":
            data.get("status")
            or data.get("result")
            or data.get("certification")
            or "UNKNOWN",
        "certified":
            data.get("certified",
                     data.get("result") == "PASS"),
        "source":str(source),
        "digest":digest(source),
        "evidence":True
    }


    target.write_text(
        json.dumps(
            normalized,
            indent=2
        )
    )

    print(
        "BRIDGED",
        engine,
        "->",
        target
    )


PY


echo
echo "== Rebuild Trust =="

./bin/wl-platform certify trust


echo
echo "== Verify =="

./bin/wl-platform verify
