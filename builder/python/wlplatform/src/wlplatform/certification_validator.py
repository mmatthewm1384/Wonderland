from __future__ import annotations

import json
from pathlib import Path

from .certification_schema import (
    validate_artifact,
    CertificationSchemaError,
)


class CertificationValidator:


    def validate(
        self,
        path: Path
    ) -> dict:

        try:
            data = json.loads(
                path.read_text(
                    encoding="utf-8"
                )
            )

            validate_artifact(data)

        except Exception as exc:
            return {
                "valid": False,
                "error": str(exc),
            }


        return {
            "valid": True,
            "certified": data["certified"],
            "engine": data["engine"],
        }
