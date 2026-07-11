from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from wlgovernance.engine import GovernanceEngine
from wlgovernance.models import CheckResult


class GovernanceEngineTests(unittest.TestCase):
    def test_version_contract(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            engine = GovernanceEngine(Path(temporary))
            result = engine.version()

            self.assertEqual(result["result"], "PASS")
            self.assertEqual(result["schema_version"], 1)

    def test_report_failure_aggregation(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            engine = GovernanceEngine(Path(temporary))

            report = engine._build_report(
                mode="verify",
                checks={
                    "required": CheckResult(
                        check_id="required",
                        status="FAIL",
                        required=True,
                        command=["false"],
                        returncode=1,
                        duration_seconds=0.1,
                    ),
                    "optional": CheckResult(
                        check_id="optional",
                        status="FAIL",
                        required=False,
                        command=["false"],
                        returncode=1,
                        duration_seconds=0.1,
                    ),
                },
            )

            self.assertEqual(report.result, "FAIL")
            self.assertEqual(
                report.failures,
                ["required"],
            )
            self.assertEqual(
                report.warnings,
                ["optional"],
            )

    def test_doctor_uses_portable_launcher_check(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            engine = GovernanceEngine(root)

            contract = engine._doctor_contract()
            command = contract["governance-launcher"]["command"]

            self.assertEqual(command[0], "/bin/test")
            self.assertEqual(command[1], "-x")
            self.assertEqual(
                Path(command[2]).resolve(),
                (
                    root
                    / "bin"
                    / "wl-governance"
                ).resolve(),
            )

    def test_atomic_state_write(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            engine = GovernanceEngine(root)

            target = root / "state.json"
            engine._write_json(
                target,
                {"result": "PASS"},
            )

            self.assertEqual(
                json.loads(
                    target.read_text(encoding="utf-8")
                ),
                {"result": "PASS"},
            )


if __name__ == "__main__":
    unittest.main()
