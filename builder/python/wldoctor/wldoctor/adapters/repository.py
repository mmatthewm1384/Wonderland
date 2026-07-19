from __future__ import annotations

import json
from pathlib import Path
from typing import Any


class RepositoryAdapter:
    name = "repository"

    def run(self, root: Path) -> dict[str, Any]:
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

        certificate_candidates = [
            root / ".state/repository/certificate.json",
        ]

        certification_root = (
            root /
            "vault" /
            "08-Operations" /
            "certifications"
        )

        if certification_root.exists():
            certificate_candidates.extend(
                sorted(
                    certification_root.glob(
                        "repository-certification*/certificate.json"
                    ),
                    reverse=True,
                )
            )

        certificate = None

        for path in certificate_candidates:
            if path.exists():
                try:
                    certificate = json.loads(
                        path.read_text(
                            encoding="utf-8"
                        )
                    )
                    break
                except Exception:
                    pass

        result["certified"] = bool(
            certificate and (
                certificate.get("certified")
                or certificate.get("result") == "PASS"
            )
        )

        if certificate:
            result["certificate"] = certificate

        return result
