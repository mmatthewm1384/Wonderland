from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from wlrepository.cli import main


class RepositoryCliTests(unittest.TestCase):
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

        (policy_dir / "policy.json").write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "engine": {
                        "id": "repository",
                        "name": "Repository",
                        "version": "test",
                    },
                    "policy": {
                        "principles": [],
                        "protected_source_prefixes": [
                            "source/"
                        ],
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
                        ],
                        "must_track": [
                            "source/module.py",
                        ],
                    },
                }
            ),
            encoding="utf-8",
        )

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def test_status_json(self) -> None:
        with patch.dict(
            "os.environ",
            {"WL_ROOT": str(self.root)},
        ):
            rc = main(["--json", "status"])

        self.assertEqual(rc, 0)

    def test_health_json(self) -> None:
        with patch.dict(
            "os.environ",
            {"WL_ROOT": str(self.root)},
        ):
            rc = main(["--json", "health"])

        self.assertIn(rc, (0, 1))

    def test_verify(self) -> None:
        with patch.dict(
            "os.environ",
            {"WL_ROOT": str(self.root)},
        ):
            rc = main(["verify"])

        self.assertIn(rc, (0, 1))

    def test_unknown_command(self) -> None:
        with self.assertRaises(SystemExit):
            main(["does-not-exist"])


if __name__ == "__main__":
    unittest.main()
