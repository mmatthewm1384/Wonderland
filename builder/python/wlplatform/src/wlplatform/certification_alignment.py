from __future__ import annotations

from pathlib import Path
import json


def certification_artifact_path(
    root: Path,
    engine: str,
) -> Path:

    return (
        root
        /
        "vault/08-Operations/certifications/normalized"
        /
        f"{engine}-certification.json"
    )


def load_artifact(
    root: Path,
    engine: str,
) -> dict:

    path = certification_artifact_path(
        root,
        engine,
    )

    if not path.exists():
        return {}

    return json.loads(
        path.read_text()
    )


def align_engine(
    root: Path,
    engine,
    artifact: dict | None = None,
) -> dict:

    artifact = artifact or load_artifact(
        root,
        engine.name,
    )

    live = engine.certify()

    live_dict = (
        live.to_dict()
        if hasattr(live, "to_dict")
        else live
    )

    return {
        "engine": engine.name,
        "live_status": live_dict.get(
            "status"
        ),
        "artifact_status": artifact.get(
            "status"
        ),
        "aligned":
            live_dict.get("status")
            ==
            artifact.get("status"),
    }


def verify_alignment(
    root: Path,
    engines,
) -> dict:

    results = [
        align_engine(
            root,
            engine,
        )
        for engine in engines
    ]

    failures = [
        item
        for item in results
        if item["artifact_status"] is not None
        and not item["aligned"]
    ]

    return {
        "result":
            "PASS"
            if not failures
            else "FAIL",
        "engines": results,
        "failures": failures,
    }
