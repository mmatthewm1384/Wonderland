from __future__ import annotations

import json
from pathlib import Path
from typing import Any


class CertificationEvidence:

    def __init__(self, root: Path):
        self.root = root.resolve()

    def _load_certificate(self, path: Path) -> dict[str, Any] | None:
        if not path.exists():
            return None

        try:
            return json.loads(
                path.read_text(
                    encoding="utf-8"
                )
            )
        except Exception:
            return None

    def discover(self) -> dict[str, Any]:
        systems: dict[str, Any] = {}

        candidates = {
            "repository": [
                self.root / ".state/repository/certificate.json",
            ],
            "runtime": [
                self.root / ".state/runtime/certificate.json",
            ],
            "builder": [
                self.root / ".state/builder/certificate.json",
            ],
            "academy": [
                self.root / ".state/academy/certificate.json",
            ],
            "governance": [
                self.root / ".state/governance/certificate.json",
            ],
        }

        for name, paths in candidates.items():
            certificate = None

            for path in paths:
                certificate = self._load_certificate(path)

                if certificate:
                    break

            systems[name] = {
                "certified": bool(
                    certificate
                    and (
                        certificate.get("certified")
                        or certificate.get("result") == "PASS"
                    )
                ),
                "certificate": certificate,
            }

        return {
            "schema_version": 1,
            "systems": systems,
            "platform_certified": all(
                item["certified"]
                for item in systems.values()
            ),
        }
