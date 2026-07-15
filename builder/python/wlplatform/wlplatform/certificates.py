from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path


def certification_dir(root: Path) -> Path:
    return (
        root
        / "vault"
        / "08-Operations"
        / "certifications"
    )


def publish_certificate_pointer(
    root: Path,
    engine: str,
    artifact: Path,
    payload: dict,
) -> Path:

    directory = certification_dir(root)

    directory.mkdir(
        parents=True,
        exist_ok=True,
    )

    pointer = (
        directory
        / f"{engine}-certification.json"
    )

    record = {
        "schema_version": 1,
        "engine": engine,
        "certified": bool(
            payload.get(
                "certified",
                False,
            )
        ),
        "verification": payload.get(
            "verification"
        ),
        "artifact": str(artifact),
        "updated": datetime.now(
            timezone.utc
        ).isoformat(),
    }

    pointer.write_text(
        json.dumps(
            record,
            indent=2,
            sort_keys=True,
        ),
        encoding="utf-8",
    )

    return pointer
