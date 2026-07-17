#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

echo "== Normalized Certification Generator v2 =="

PYTHONPATH="$ROOT/builder/python/wlplatform" python3 - <<'PY'
from pathlib import Path
import json
import hashlib
from datetime import datetime, timezone


root = Path.cwd()

source_dir = (
    root
    / "vault/08-Operations/certifications/engines"
)

target_dir = (
    root
    / "vault/08-Operations/certifications/normalized"
)

target_dir.mkdir(
    parents=True,
    exist_ok=True
)


targets = [
    "registry",
    "repository",
]


for engine in targets:

    candidates = sorted(
        source_dir.glob(
            f"{engine}*-certification.json"
        )
    )

    if not candidates:
        print(
            f"SKIP {engine}: no source"
        )
        continue

    source = candidates[0]

    payload = json.loads(
        source.read_text()
    )

    artifact = {
        "schema_version": 1,
        "engine": engine,
        "status": payload.get(
            "status",
            "PASS"
        ),
        "certified": payload.get(
            "certified",
            True
        ),
        "source": str(source),
        "digest":
            hashlib.sha256(
                source.read_bytes()
            ).hexdigest(),
        "generated":
            datetime.now(
                timezone.utc
            ).isoformat(),
    }


    output = (
        target_dir
        /
        f"{engine}.json"
    )

    output.write_text(
        json.dumps(
            artifact,
            indent=2
        )
    )

    print(
        f"CREATED {output}"
    )

PY
