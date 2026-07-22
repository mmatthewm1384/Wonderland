from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone


def artifact_digest(payload: dict) -> str:
    data = json.dumps(
        payload,
        sort_keys=True,
    ).encode()

    return (
        "sha256:"
        + hashlib.sha256(data)
        .hexdigest()
    )


def create_lineage(
    *,
    engine: str,
    version: str = "1.0.0",
    artifact: dict,
    previous_digest: str | None = None,
):
    return {
        "engine": engine,
        "engine_version": version,
        "generated_at": (
            datetime.now(
                timezone.utc
            )
            .isoformat()
        ),
        "artifact_digest": (
            artifact_digest(artifact)
        ),
        "previous_digest": previous_digest,
    }



class CertificationLineage:
    """Compatibility wrapper for CLI certification lineage commands."""

    def __init__(
        self,
        root,
    ):
        self.root = root


    def build(self):
        from pathlib import Path
        import json

        root = Path(
            self.root
        )

        cert_root = (
            root
            /
            "vault/08-Operations/certifications/normalized"
        )

        records = []

        if cert_root.exists():

            for artifact in sorted(
                cert_root.glob(
                    "*-certification.json"
                )
            ):

                payload = json.loads(
                    artifact.read_text()
                )

                records.append(
                    create_lineage(
                        artifact=payload,
                        engine=payload.get(
                            "engine",
                            artifact.stem.replace(
                                "-certification",
                                "",
                            ),
                        ),
                    )
                )


        return {
            "schema_version": 1,
            "lineage_count": len(records),
            "lineage": records,
        }


def persist_lineage(root):

    from pathlib import Path
    import json

    root = Path(root)

    cert_root = (
        root
        /
        "vault/08-Operations/certifications/normalized"
    )

    updated = []

    for artifact in sorted(cert_root.glob("*.json")):

        payload = json.loads(
            artifact.read_text()
        )

        engine = payload.get(
            "engine",
            artifact.stem.replace(
                "-certification",
                "",
            ),
        )

        payload["lineage"] = create_lineage(
            engine=engine,
            artifact=payload,
        )

        artifact.write_text(
            json.dumps(
                payload,
                indent=2,
                sort_keys=True,
            )
            + "\n"
        )

        updated.append(engine)

    return {
        "command": "persist-lineage",
        "updated": updated,
        "count": len(updated),
        "result": "PASS",
    }
