
import json
import tempfile
import unittest
from pathlib import Path
import importlib.util

MODULE = Path(__file__).resolve().parents[1] / "lib" / "ytmusic.py"
spec = importlib.util.spec_from_file_location("ytmusic_phase2b", MODULE)
ytmusic = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ytmusic)


class Phase2BBatchTests(unittest.TestCase):
    def setUp(self):
        self.cfg = {
            "format": "bestaudio[ext=m4a]",
            "audio_quality_policy": "preserve_source",
        }
        self.document = {
            "schema": "wonderland.ytmusic.batch.v1",
            "batch_id": "20261105-001",
            "state": "approved",
            "approval": {
                "identity_approval": True,
                "approved_track_count": 1,
                "maximum_batch_size": 10,
                "format": "m4a",
                "transcoding": False,
            },
            "tracks": [{
                "position": 1,
                "title": "SEROTONIN",
                "artist": "LaLion",
                "video_id": "MtAsU2cGKxs",
                "expected_uploader": "LaLion",
                "identity_status": "approved",
            }],
            "excluded": [],
        }

    def test_valid_approval_contract(self):
        tracks = ytmusic.validate_batch_document(self.document, self.cfg)
        self.assertEqual(len(tracks), 1)
        self.assertEqual(tracks[0]["video_id"], "MtAsU2cGKxs")

    def test_unapproved_batch_rejected(self):
        self.document["state"] = "draft"
        with self.assertRaisesRegex(RuntimeError, "not approved"):
            ytmusic.validate_batch_document(self.document, self.cfg)

    def test_identity_approval_required(self):
        self.document["approval"]["identity_approval"] = False
        with self.assertRaisesRegex(RuntimeError, "Identity approval"):
            ytmusic.validate_batch_document(self.document, self.cfg)

    def test_batch_limit_enforced(self):
        self.document["approval"]["maximum_batch_size"] = 11
        with self.assertRaisesRegex(RuntimeError, "controlled limit"):
            ytmusic.validate_batch_document(self.document, self.cfg)

    def test_duplicate_video_id_rejected(self):
        second = dict(self.document["tracks"][0], position=2)
        self.document["tracks"].append(second)
        self.document["approval"]["approved_track_count"] = 2
        with self.assertRaisesRegex(RuntimeError, "Duplicate"):
            ytmusic.validate_batch_document(self.document, self.cfg)

    def test_excluded_video_id_cannot_be_approved(self):
        self.document["excluded"] = [{
            "video_id": "MtAsU2cGKxs",
            "reason": "excluded",
        }]
        with self.assertRaisesRegex(RuntimeError, "Excluded"):
            ytmusic.validate_batch_document(self.document, self.cfg)

    def test_positions_must_be_contiguous(self):
        self.document["tracks"][0]["position"] = 2
        with self.assertRaisesRegex(RuntimeError, "contiguous"):
            ytmusic.validate_batch_document(self.document, self.cfg)


if __name__ == "__main__":
    unittest.main()
