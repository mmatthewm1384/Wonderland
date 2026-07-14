from __future__ import annotations

import json
from pathlib import Path
from typing import Any


class RepositoryAdapter:
    name = "repository"

    def run(self, root: Path) -> dict[str, Any]:
        result: dict[str, Any]

        try:
            from wlrepository.engine import RepositoryEngine

            result = RepositoryEngine(root).doctor()
        except Exception as exc:
            result = {
                "schema_version": 1,
                "engine": "repository",
                "status": "FAIL",
                "error": str(exc),
            }

        certificate_path = (
            root
            / ".state"
            / "repository"
            / "certificate.json"
        )

        certified = False
        certificate: dict[str, Any] | None = None

        if certificate_path.exists():
            try:
                certificate = json.loads(
                    certificate_path.read_text(
                        encoding="utf-8"
                    )
                )

                certified = bool(
                    certificate.get("certified")
                )

            except Exception:
                certified = False

        result["certified"] = certified

        if certificate is not None:
            result["certificate"] = certificate

        return result
