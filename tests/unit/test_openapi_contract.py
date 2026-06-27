from __future__ import annotations

import json
import subprocess
import unittest
from pathlib import Path


ROOT = Path.home() / "Wonderland"


class OpenAPIContractTests(unittest.TestCase):
    def test_openapi_file_has_required_paths(self):
        data = json.loads((ROOT / "docs/api/openapi.json").read_text())

        required = [
            "/version",
            "/ready",
            "/status",
            "/state",
            "/services",
            "/events",
            "/timeline",
            "/drift",
            "/schema",
            "/config",
            "/metrics",
            "/stream",
            "/plugins",
        ]

        for path in required:
            self.assertIn(path, data["paths"])

    def test_openapi_endpoint_serves_spec(self):
        p = subprocess.run(
            ["curl", "-fsS", "http://127.0.0.1:9105/api/v1/openapi.json"],
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertEqual(p.returncode, 0, p.stderr)
        data = json.loads(p.stdout)
        self.assertEqual(data["info"]["title"], "Wonderland Platform API")
        self.assertIn("/ready", data["paths"])


if __name__ == "__main__":
    unittest.main()
