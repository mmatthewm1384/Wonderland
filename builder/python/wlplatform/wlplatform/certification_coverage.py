from __future__ import annotations

from pathlib import Path
import json

from .certification_normalizer import (
    normalize_certification,
)


CERT_ROOT = (
    "vault/08-Operations/certifications/normalized"
)


def artifact_path(
    root: Path,
    engine: str,
):
    return (
        root
        /
        CERT_ROOT
        /
        f"{engine}-certification.json"
    )


def certification_coverage(
    root: Path,
    engines: list[str],
):

    results = []

    for name in engines:

        path = artifact_path(
            root,
            name,
        )

        exists = path.exists()

        artifact = {}

        if exists:
            artifact = json.loads(
                path.read_text()
            )

        normalized = normalize_certification(
            artifact
        )

        normalized["engine"] = name

        results.append(
            {
                "engine": name,
                "artifact_exists": exists,
                **normalized,
            }
        )

    missing = [
        item["engine"]
        for item in results
        if not item["artifact_exists"]
    ]

    return {
        "result":
            "PASS"
            if not missing
            else "WARN",
        "total":
            len(results),
        "certified":
            len(
                [
                    x
                    for x in results
                    if x["certified"]
                ]
            ),
        "missing": missing,
        "engines": results,
    }
