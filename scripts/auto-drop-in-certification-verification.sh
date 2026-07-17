#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

TARGET="builder/python/wlplatform/wlplatform/verification.py"

cp "$TARGET" "$TARGET.backup.$(date +%Y%m%d-%H%M%S)"

cat > "$TARGET" <<'PY'
from __future__ import annotations

import subprocess
from pathlib import Path

from .certification import certify


class PlatformVerificationEngine:

    def __init__(
        self,
        root: Path,
    ) -> None:
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

        certification = certify(
            self.root
        )

        checks = {}

        engines = certification.get(
            "engines",
            {}
        )

        for engine, status in engines.items():

            checks[
                f"{engine}_certified"
            ] = (
                status == "PASS"
            )


        checks[
            "repository_clean"
        ] = self.repository_clean()


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
            //
            len(checks)
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
PY


echo "Verification engine migrated."
