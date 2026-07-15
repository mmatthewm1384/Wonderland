from __future__ import annotations

import subprocess
from pathlib import Path

from .certification import (
    PlatformCertificationEngine,
)


class PlatformVerificationEngine:

    def __init__(
        self,
        root: Path,
    ) -> None:
        self.root = root.resolve()

    def repository_clean(
        self,
    ) -> bool:

        result = subprocess.run(
            [
                "git",
                "status",
                "--porcelain",
            ],
            cwd=self.root,
            text=True,
            capture_output=True,
        )

        return (
            result.returncode == 0
            and not result.stdout.strip()
        )

    def verify(self) -> dict:

        graph = (
            PlatformCertificationEngine(
                self.root
            )
            .graph()
        )

        checks: dict[str, bool] = {
            "repository_clean":
                self.repository_clean(),
        }

        for engine, state in graph.items():

            checks[
                f"{engine}_certified"
            ] = bool(
                state.get(
                    "certified",
                    False,
                )
            )

        checks[
            "platform_graph_complete"
        ] = all(
            item.get("status")
            != "MISSING"
            for item in graph.values()
        )

        passed = all(
            checks.values()
        )

        score = (
            sum(
                1
                for value in checks.values()
                if value
            )
            * 100
            // len(checks)
        )

        return {
            "schema_version": 1,
            "engine": "platform",
            "version": "1.1",
            "certification":
                "Wonderland Platform Verification",
            "checks": checks,
            "health_score": score,
            "result":
                "PASS"
                if passed
                else "FAIL",
        }
