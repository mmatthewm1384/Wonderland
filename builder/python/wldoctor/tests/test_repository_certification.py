from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from wldoctor.engine import DoctorEngine


class RepositoryCertificationTests(unittest.TestCase):

    def test_repository_certification_evidence_is_reported(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)

            state = root / ".state/repository"
            state.mkdir(parents=True)

            certificate = {
                "schema_version": 1,
                "engine": "repository",
                "version": "1.2.4",
                "certified": True,
                "verification": "PASS",
                "health_score": 100,
            }

            (
                state / "certificate.json"
            ).write_text(
                json.dumps(certificate),
                encoding="utf-8",
            )

            report = DoctorEngine(root).doctor()

            self.assertIn(
                "repository",
                report["certification"]["systems"],
            )

            self.assertTrue(
                report["certification"]["systems"]
                ["repository"]
                ["certified"]
            )


if __name__ == "__main__":
    unittest.main()
