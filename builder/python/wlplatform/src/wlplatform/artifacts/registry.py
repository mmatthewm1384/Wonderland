"""
Wonderland Artifact Registry Engine.

Indexes vertical artifacts by identity.
"""

from pathlib import Path
import json


class ArtifactRegistry:


    def __init__(
        self,
        path
    ):

        self.path = Path(path)

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True
        )


    def register(
        self,
        artifact: dict
    ):

        record = {

            "artifact_id":
                artifact["identity"]["artifact_id"],

            "digest":
                artifact["identity"]["digest"],

            "type":
                artifact["artifact"]["type"],

            "engine":
                artifact["provenance"]["engine"],

            "source_event":
                artifact["provenance"]["source_event"],

            "trust":
                artifact["trust"]["level"],

            "certification":
                artifact["certification"]["status"]

        }


        with self.path.open(
            "a",
            encoding="utf-8"
        ) as file:

            file.write(
                json.dumps(
                    record,
                    indent=2
                )
                + "\n"
            )


    def find(
        self,
        artifact_id
    ):


        if not self.path.exists():
            return None


        with self.path.open(
            encoding="utf-8"
        ) as file:

            for line in file:

                record = json.loads(
                    line
                )

                if record.get(
                    "artifact_id"
                ) == artifact_id:

                    return record


        return None
