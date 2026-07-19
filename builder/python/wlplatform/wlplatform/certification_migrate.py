from __future__ import annotations

import json
from pathlib import Path

from .certification_lineage import create_lineage


CERT_ROOT = (
    "vault/08-Operations/"
    "certifications/normalized"
)


def migrate_certifications(root):

    root = Path(root)

    cert_root = (
        root / CERT_ROOT
    )

    migrated = []

    for path in sorted(
        cert_root.glob("*-certification.json")
    ):

        payload = json.loads(
            path.read_text()
        )

        engine = payload.get("engine")

        if not engine:
            continue

        if "lineage" in payload:
            migrated.append(
                {
                    "engine": engine,
                    "status": "SKIP",
                }
            )
            continue

        lineage = create_lineage(
            engine=engine,
            artifact=payload,
        )

        payload["lineage"] = lineage

        path.write_text(
            json.dumps(
                payload,
                indent=2,
            )
            + "\n"
        )

        migrated.append(
            {
                "engine": engine,
                "status": "MIGRATED",
            }
        )

    return {
        "result": "PASS",
        "migrated": migrated,
    }
