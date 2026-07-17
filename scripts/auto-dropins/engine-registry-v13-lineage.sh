#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Engine Registry v1.3 Lineage =="

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

ENGINE_DIR="$ROOT/builder/python/wlplatform/wlplatform/engines"

cat > "$ENGINE_DIR/lineage.py" <<'PY'
from __future__ import annotations

from datetime import datetime, timezone

from .catalog import ENGINE_CATALOG


def engine_record(name):

    if name not in ENGINE_CATALOG:
        raise ValueError(
            f"Unknown engine: {name}"
        )

    spec = ENGINE_CATALOG[name]

    return {
        "engine": name,
        "owner": f"platform.{name}",
        "version": "1.3.0",

        "capabilities":
            spec["capabilities"],

        "dependencies":
            spec["depends_on"],

        "certification": {
            "status": "UNVERIFIED",
            "artifact": (
                "vault/08-Operations/"
                "certifications/engines/"
                f"{name}-certification.json"
            )
        },

        "lineage": {
            "created_by":
                "engine-registry-v1.3",
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
    }


def all_records():

    return {
        name: engine_record(name)
        for name in ENGINE_CATALOG
    }
PY


echo "Lineage layer installed"
