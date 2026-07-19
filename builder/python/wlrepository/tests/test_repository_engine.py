from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

from wlrepository.engine import RepositoryEngine


class RepositoryEngineTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)

        subprocess.run(
            ["git", "init", "-q"],
            cwd=self.root,
            check=True,
        )

        policy_dir = self.root / "policy/repository"
        policy_dir.mkdir(parents=True)

        policy = {
            "schema_version": 1,
            "engine": {
                "id": "repository",
                "name": "Repository",
                "version": "test",
            },
            "policy": {
                "principles": [],
                "protected_source_prefixes": ["source/"],
                "sections": [
                    {
                        "name": "Generated",
                        "patterns": [
                            "**/target/",
                            "*.log",
                        ],
                    }
                ],
                "must_ignore": [
                    "apps/demo/target/debug/demo",
                    "runtime.log",
                ],
                "must_track": [
                    "source/module.py",
                ],
            },
        }

        (policy_dir / "policy.json").write_text(
            json.dumps(policy),
            encoding="utf-8",
        )

        self.engine = RepositoryEngine(self.root)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def test_generate_is_deterministic(self) -> None:
        first = self.engine.render_gitignore()
        second = self.engine.render_gitignore()
        self.assertEqual(first, second)

    def test_generate_writes_gitignore(self) -> None:
        self.engine.generate()
        self.assertTrue((self.root / ".gitignore").exists())
        self.assertTrue(self.engine.generate(check_only=True))

    def test_check_ignore_uses_repository_policy(self) -> None:
        self.engine.generate()

        ignored, _ = self.engine.check_ignore(
            "apps/demo/target/debug/demo"
        )
        self.assertTrue(ignored)

        ignored, _ = self.engine.check_ignore(
            "source/module.py"
        )
        self.assertFalse(ignored)

    def test_verify_passes(self) -> None:
        self.engine.generate()
        result = self.engine.verify()
        self.assertTrue(result.passed, result.as_dict())


    def test_policy_digest_is_stable(self) -> None:
        first = self.engine.policy_digest()
        second = self.engine.policy_digest()

        self.assertEqual(first, second)
        self.assertEqual(len(first), 64)

    def test_health_reports_score(self) -> None:
        self.engine.generate()

        health = self.engine.health()

        self.assertEqual(health["result"], "PASS")
        self.assertIn("score", health)
        self.assertIn("errors", health)
        self.assertIn("warnings", health)

    def test_certification_returns_valid_contract(self) -> None:
        self.engine.generate()

        certification = self.engine.certification()

        self.assertEqual(
            certification["engine"],
            "repository",
        )
        self.assertEqual(
            certification["version"],
            "1.2.4",
        )

        self.assertEqual(
            certification["schema_version"],
            1,
        )

        self.assertIn(
            "state_digest",
            certification,
        )
        self.assertTrue(
            certification["certified"],
        )
        self.assertEqual(
            certification["verification"],
            "PASS",
        )
        self.assertEqual(
            certification["health_score"],
            100,
        )
        self.assertEqual(
            len(certification["policy_digest"]),
            64,
        )
        self.assertEqual(
            len(certification["generated_digest"]),
            64,
        )


    def test_policy_drift_detection(self) -> None:
        self.engine.generate()

        policy = self.engine.policy_path.read_text(
            encoding="utf-8"
        )

        self.engine.policy_path.write_text(
            policy + "\n",
            encoding="utf-8",
        )

        result = self.engine.verify()

        codes = [
            item.code
            for item in result.findings
        ]

        self.assertIn(
            "POLICY_DIGEST_MISMATCH",
            codes,
        )

    def test_status_contains_verification_state(self) -> None:
        self.engine.generate()

        status = self.engine.status()

        self.assertIn("generated_digest", status)
        self.assertIn("current_digest", status)
        self.assertTrue(status["synchronized"])


if __name__ == "__main__":
    unittest.main()


    def test_snapshot_creates_repository_evidence(self) -> None:
        self.engine.generate()

        snapshot = self.engine.snapshot()

        self.assertEqual(
            snapshot["engine"],
            "repository",
        )

        self.assertEqual(
            snapshot["schema_version"],
            1,
        )

        self.assertEqual(
            len(snapshot["policy_digest"]),
            64,
        )

        self.assertEqual(
            len(snapshot["generated_digest"]),
            64,
        )


    def test_drift_returns_contract(self) -> None:
        self.engine.generate()

        drift = self.engine.drift()

        self.assertIn(
            "result",
            drift,
        )

        self.assertIn(
            "changes",
            drift,
        )
