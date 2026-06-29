from __future__ import annotations

import json
import subprocess
import unittest


class APIContractTests(unittest.TestCase):
    def curl_json(self, path: str):
        p = subprocess.run(
            ["curl", "-fsS", f"http://127.0.0.1:9105{path}"],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(p.returncode, 0, p.stderr)
        return json.loads(p.stdout)

    def test_ready_endpoint_contract(self):
        data = self.curl_json("/api/v1/ready")

        self.assertIn("ready", data)
        self.assertIn("services_ready", data)
        self.assertIn("services_total", data)
        self.assertIn("drifted", data)

    def test_version_endpoint_contract(self):
        data = self.curl_json("/api/v1/version")

        self.assertEqual(data["platform"], "Wonderland")
        self.assertIn("version", data)
        self.assertIn("schema", data)
        self.assertEqual(data["api"], "v1")

    def test_drift_endpoint_contract(self):
        data = self.curl_json("/api/v1/drift")

        self.assertIn("drifted", data)
        self.assertIn("services", data)


if __name__ == "__main__":
    unittest.main()
