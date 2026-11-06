import unittest
import importlib.util
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1] / "lib" / "ytmusic.py"
spec = importlib.util.spec_from_file_location("ytmusic_phase2c_tests", MODULE)
ytmusic = importlib.util.module_from_spec(spec)
import sys
sys.modules[spec.name] = ytmusic
spec.loader.exec_module(ytmusic)


class Phase2CTitleMatcherTests(unittest.TestCase):
    def test_artist_prefix_and_suffix_are_allowed(self):
        self.assertTrue(
            ytmusic._title_contains_sequence(
                "LaLion - SEROTONIN (Prod. LaLion)", "SEROTONIN"
            )
        )

    def test_exact_token_sequence_is_required(self):
        self.assertFalse(
            ytmusic._title_contains_sequence("Artist - SEROTONINX", "SEROTONIN")
        )

    def test_token_order_is_preserved(self):
        self.assertFalse(
            ytmusic._title_contains_sequence("Artist - Bones Skin", "Skin Bones")
        )

    def test_empty_expected_title_fails_closed(self):
        self.assertFalse(
            ytmusic._title_contains_sequence("Artist - Track", "")
        )


class Phase2CRecoveryEvidenceTests(unittest.TestCase):
    def test_non_recovered_record_needs_no_recovery_evidence(self):
        self.assertIsNone(
            ytmusic._batch_verify_recovery_evidence(
                {"manifest_dir": Path("/tmp")},
                {"recovered": False},
                {},
                {},
            )
        )

    def test_recovered_record_requires_evidence_reference(self):
        with self.assertRaises(RuntimeError):
            ytmusic._batch_verify_recovery_evidence(
                {"manifest_dir": Path("/tmp")},
                {"recovered": True},
                {},
                {},
            )

    def test_recovered_record_video_id_must_match_approved_track(self):
        with self.assertRaisesRegex(RuntimeError, "does not match approved track"):
            ytmusic._batch_verify_recovery_evidence(
                {"manifest_dir": Path("/tmp")},
                {"recovered": True, "video_id": "wrong-id"},
                {"video_id": "MtAsU2cGKxs"},
                {},
            )


if __name__ == "__main__":
    unittest.main()
