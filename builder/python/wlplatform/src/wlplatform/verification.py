from __future__ import annotations

import subprocess
from pathlib import Path

from .engine import PlatformCertificationEngine

from .certification_state import CertificationState


class PlatformVerificationEngine:

    def __init__(self, root: Path):
        self.root = root.resolve()


    def repository_clean(self) -> bool:

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

        certification = PlatformCertificationEngine(
            self.root
        ).certify()


        engines = certification.get(
            "engines",
            {}
        )


        checks = {
            "repository_clean":
                self.repository_clean(),
        }


        for name, status in engines.items():

            checks[
                f"{name}_certified"
            ] = (
                status == "PASS"
            )


        certification_checks = {
            key: value
            for key, value in checks.items()
            if key != "repository_clean"
        }

        passed = all(
            certification_checks.values()
        )


        score = (
            sum(checks.values())
            * 100
            //
            len(checks)
        )


        return {
            "schema_version": 1,
            "engine": "platform",
            "version": "1.1",
            "checks": checks,
            "workspace": {
                "repository_clean":
                    checks.get(
                        "repository_clean",
                        False,
                    )
            },
            "health_score": score,
            "result":
                "PASS"
                if passed
                else "FAIL",
        }
