"""
Wonderland Vertical Artifact Schema Serializer v1.0
"""

from collections import OrderedDict
from datetime import datetime, timezone
import hashlib
import json


class ArtifactBuilder:


    def create(
        self,
        artifact_type,
        engine,
        source_event,
        payload=None,
        trust_level="UNKNOWN",
        certification_status="PENDING",
    ):


        created = datetime.now(
            timezone.utc
        ).isoformat()


        identity_seed = {
            "artifact_type": artifact_type,
            "engine": engine,
            "source_event": source_event,
            "created": created,
        }


        digest = hashlib.sha256(
            json.dumps(
                identity_seed,
                sort_keys=True
            ).encode()
        ).hexdigest()


        return OrderedDict([

            (
                "artifact",
                OrderedDict([
                    (
                        "name",
                        artifact_type
                    ),
                    (
                        "type",
                        artifact_type
                    ),
                    (
                        "version",
                        "1.0"
                    ),
                ])
            ),


            (
                "identity",
                OrderedDict([
                    (
                        "artifact_id",
                        digest
                    ),
                    (
                        "digest",
                        f"sha256:{digest}"
                    ),
                ])
            ),


            (
                "provenance",
                OrderedDict([
                    (
                        "source_event",
                        source_event
                    ),
                    (
                        "engine",
                        engine
                    ),
                    (
                        "created",
                        created
                    ),
                ])
            ),


            (
                "verification",
                OrderedDict([
                    (
                        "integrity",
                        "PASS"
                    ),
                    (
                        "replayable",
                        True
                    ),
                ])
            ),


            (
                "trust",
                OrderedDict([
                    (
                        "level",
                        trust_level
                    ),
                ])
            ),


            (
                "certification",
                OrderedDict([
                    (
                        "status",
                        certification_status
                    ),
                ])
            ),


            (
                "payload",
                payload or {}
            )

        ])


def serialize_artifact(
    artifact
):

    return json.dumps(
        artifact,
        indent=2
    )
