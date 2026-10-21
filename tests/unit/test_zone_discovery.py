import json
import tempfile
import unittest
from pathlib import Path

from scripts.wonderland.zone_discover import discover


class ZoneDiscoveryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.candidates = self.root / "config/wonderland/environments/candidates"
        self.candidates.mkdir(parents=True)

    def tearDown(self):
        self.temp.cleanup()

    def write_candidate(self, filename, payload):
        path = self.candidates / filename
        path.write_text(json.dumps(payload), encoding="utf-8")
        return path

    @staticmethod
    def manifest(identity, kind="imagined", name="Test Environment"):
        metadata = {"name": name}
        if identity is not None:
            metadata["id"] = identity
        return {
            "apiVersion": "wonderland.dev/v1",
            "kind": "Environment",
            "metadata": metadata,
            "spec": {"environmentKind": kind},
        }

    def test_discovers_candidate_without_enrolling_or_authorizing(self):
        path = self.write_candidate("one.json", self.manifest("dream-garden", name="Dream Garden"))
        before = path.read_bytes()
        result = discover(self.root, Path("config/wonderland/environments/candidates"))
        self.assertEqual(result["candidate_count"], 1)
        self.assertEqual(result["candidates"][0]["id"], "dream-garden")
        self.assertEqual(result["candidates"][0]["discovery_state"], "discovered")
        self.assertFalse(result["candidates"][0]["enrolled"])
        self.assertFalse(result["candidates"][0]["authorized"])
        self.assertFalse(result["side_effects"])
        self.assertEqual(path.read_bytes(), before)

    def test_results_are_deterministically_sorted(self):
        self.write_candidate("z.json", self.manifest("z"))
        self.write_candidate("a.json", self.manifest("a"))
        first = discover(self.root, Path("config/wonderland/environments/candidates"))
        second = discover(self.root, Path("config/wonderland/environments/candidates"))
        self.assertEqual(first, second)
        self.assertEqual([c["id"] for c in first["candidates"]], ["a", "z"])

    def test_duplicate_identity_is_reported_not_silently_merged(self):
        self.write_candidate("one.json", self.manifest("same"))
        self.write_candidate("two.json", self.manifest("same"))
        result = discover(self.root, Path("config/wonderland/environments/candidates"))
        self.assertEqual(result["candidate_count"], 1)
        self.assertIn("identity_collision", [d["code"] for d in result["diagnostics"]])

    def test_missing_id_gets_provisional_candidate_identity(self):
        self.write_candidate("one.json", self.manifest(None))
        result = discover(self.root, Path("config/wonderland/environments/candidates"))
        self.assertEqual(result["candidate_count"], 1)
        self.assertEqual(result["candidates"][0]["identity_status"], "provisional")
        self.assertTrue(result["candidates"][0]["id"].startswith("candidate-"))

    def test_invalid_json_is_reported(self):
        (self.candidates / "broken.json").write_text("{", encoding="utf-8")
        result = discover(self.root, Path("config/wonderland/environments/candidates"))
        self.assertEqual(result["candidate_count"], 0)
        self.assertIn("invalid_json", [d["code"] for d in result["diagnostics"]])

    def test_invalid_environment_manifest_is_rejected(self):
        self.write_candidate("bad.json", {
            "apiVersion": "wrong/v9",
            "kind": "Environment",
            "metadata": {"name": "Bad"},
            "spec": {"environmentKind": "telepathic"},
        })
        result = discover(self.root, Path("config/wonderland/environments/candidates"))
        self.assertEqual(result["candidate_count"], 0)
        self.assertIn("invalid_environment_manifest", [d["code"] for d in result["diagnostics"]])

    def test_path_escape_is_rejected(self):
        with self.assertRaises(ValueError):
            discover(self.root, self.root.parent)

    def test_missing_directory_is_safe_empty_result(self):
        result = discover(self.root, Path("not-created"))
        self.assertEqual(result["candidate_count"], 0)
        self.assertFalse(result["side_effects"])


if __name__ == "__main__":
    unittest.main()
