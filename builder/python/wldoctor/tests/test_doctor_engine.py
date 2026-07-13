from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from wldoctor.engine import DoctorEngine


class DoctorEngineTests(unittest.TestCase):

    def test_certification_summary(self):
        with tempfile.TemporaryDirectory() as tmp:
            report = DoctorEngine(
                Path(tmp)
            ).doctor()

            self.assertIn(
                "certification",
                report,
            )

            self.assertIn(
                "overall",
                report["certification"],
            )


    def test_schema_contract(self):
        with tempfile.TemporaryDirectory() as tmp:
            report = DoctorEngine(
                Path(tmp)
            ).doctor()

            self.assertEqual(
                report["schema_version"],
                1,
            )

            self.assertEqual(
                report["engine"],
                "wonderland-doctor",
            )

            self.assertIn(
                report["status"],
                ("PASS", "FAIL"),
            )


if __name__ == "__main__":
    unittest.main()
