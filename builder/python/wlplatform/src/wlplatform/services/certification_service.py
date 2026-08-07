#!/usr/bin/env python3
"""
Wonderland Certification Service

Owns certification workflows.

Responsibilities
----------------
- Execute certification
- Generate evidence
- Generate certification artifacts
- Verify artifacts
- Return certification results

Does NOT own CLI routing.
"""

from __future__ import annotations

from datetime import UTC, datetime
from pathlib import Path
import json

from wlplatform.services.lima_service import LimaService


class CertificationService:

    def __init__(self, root):
        self.root = Path(root)

    def certify_lima(self):

        lima = LimaService(self.root)

        checks = lima.run_checks()

        if not checks["certified"]:
            return {
                "status": "FAILED",
                "checks": checks,
            }

        evidence = lima.generate_evidence()

        cert_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "lima"
        )

        cert_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

        timestamp = datetime.now(UTC)

        cert_path = (
            cert_dir
            / (
                "wonderland-rootless-"
                + timestamp.strftime("%Y%m%dT%H%M%SZ")
                + ".json"
            )
        )

        artifact = {
            "component": "wonderland-rootless",
            "status": "CERTIFIED",
            "timestamp": timestamp.isoformat(),
            "checks": checks,
            "evidence": str(evidence),
        }

        cert_path.write_text(
            json.dumps(
                artifact,
                indent=4,
            )
        )

        verification = lima.verify_certification_artifact(
            cert_path
        )

        return {
            "status": "CERTIFIED",
            "artifact": cert_path,
            "verification": verification,
            "checks": checks,
        }
