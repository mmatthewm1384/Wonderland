from __future__ import annotations

from pathlib import Path
from typing import Any


class RepositoryAdapter:
    name = "repository"

    def run(self, root: Path) -> dict[str, Any]:
        try:
            from wlrepository.engine import RepositoryEngine

            report = RepositoryEngine(root).doctor()

            if not isinstance(report, dict):
                raise RuntimeError(
                    "repository doctor returned invalid report"
                )

            report.setdefault(
                "schema_version",
                1,
            )

            report.setdefault(
                "engine",
                self.name,
            )

            return report

        except Exception as exc:
            return {
                "schema_version": 1,
                "engine": self.name,
                "status": "FAIL",
                "error": str(exc),
                "certified": False,
            }
