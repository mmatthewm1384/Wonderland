import json
import tempfile
import unittest
from pathlib import Path
import importlib.util

MODULE = Path(__file__).resolve().parents[1] / "lib" / "ytmusic.py"
spec = importlib.util.spec_from_file_location("ytmusic_phase2a", MODULE)
ytmusic = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ytmusic)


class Phase2AGuardTests(unittest.TestCase):
    def test_extract_video_id(self):
        self.assertEqual(
            ytmusic.extract_video_id("https://youtu.be/MtAsU2cGKxs"),
            "MtAsU2cGKxs",
        )
        self.assertEqual(
            ytmusic.extract_video_id(
                "https://www.youtube.com/watch?v=MtAsU2cGKxs"
            ),
            "MtAsU2cGKxs",
        )

    def test_identity_normalization(self):
        self.assertEqual(
            ytmusic.normalize_identity("Skin & Bones"),
            ytmusic.normalize_identity("skin-bones"),
        )

    def test_metadata_rejects_wrong_id(self):
        with tempfile.TemporaryDirectory() as tmp:
            media = Path(tmp) / "track.m4a"
            media.touch()
            media.with_suffix(".info.json").write_text(json.dumps({
                "id": "wrong-video-id", "title": "SEROTONIN",
                "uploader": "LaLion",
            }))
            with self.assertRaisesRegex(RuntimeError, "identity mismatch"):
                ytmusic.verify_track_metadata(media, "MtAsU2cGKxs")

    def test_metadata_accepts_approved_identity(self):
        with tempfile.TemporaryDirectory() as tmp:
            media = Path(tmp) / "track.m4a"
            media.touch()
            media.with_suffix(".info.json").write_text(json.dumps({
                "id": "MtAsU2cGKxs", "title": "SEROTONIN",
                "uploader": "LaLion",
            }))
            result = ytmusic.verify_track_metadata(
                media, "MtAsU2cGKxs",
                {"title": "SEROTONIN", "expected_uploader": "LaLion"},
            )
            self.assertEqual(result["id"], "MtAsU2cGKxs")

    def test_metadata_rejects_wrong_uploader(self):
        with tempfile.TemporaryDirectory() as tmp:
            media = Path(tmp) / "track.m4a"
            media.touch()
            media.with_suffix(".info.json").write_text(json.dumps({
                "id": "MtAsU2cGKxs", "title": "SEROTONIN",
                "uploader": "Other Channel",
            }))
            with self.assertRaisesRegex(RuntimeError, "Uploader identity"):
                ytmusic.verify_track_metadata(
                    media, "MtAsU2cGKxs",
                    {"title": "SEROTONIN", "expected_uploader": "LaLion"},
                )

    def test_incoming_source_duplicate_is_blocked(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            paths = {name: root / name for name in
                     ("incoming", "staging", "quarantine", "manifests")}
            for path in paths.values():
                path.mkdir()
            (paths["incoming"] / "SEROTONIN [MtAsU2cGKxs].m4a").touch()
            with self.assertRaisesRegex(RuntimeError, "already exists"):
                ytmusic.check_source_duplicates({
                    "incoming_dir": paths["incoming"],
                    "staging_dir": paths["staging"],
                    "quarantine_dir": paths["quarantine"],
                    "manifest_dir": paths["manifests"],
                }, "MtAsU2cGKxs")

    def test_historical_job_blocks_duplicate(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            paths = {name: root / name for name in
                     ("incoming", "staging", "quarantine", "manifests")}
            for path in paths.values():
                path.mkdir()
            work = paths["staging"] / "old-job"
            work.mkdir()
            (paths["manifests"] / "old.json").write_text(json.dumps({
                "schema": "wonderland.ytmusic.job.v1",
                "job_id": "old-job",
                "source_url": "https://youtu.be/MtAsU2cGKxs",
                "state": "failed",
                "artifacts": [],
                "staging_directory": str(work),
            }))
            with self.assertRaisesRegex(RuntimeError, "historical job"):
                ytmusic.check_source_duplicates({
                    "incoming_dir": paths["incoming"],
                    "staging_dir": paths["staging"],
                    "quarantine_dir": paths["quarantine"],
                    "manifest_dir": paths["manifests"],
                }, "MtAsU2cGKxs")

    def test_skin_bones_exception_requires_empty_staging(self):
        with tempfile.TemporaryDirectory() as tmp:
            work = Path(tmp) / "old"
            work.mkdir()
            manifest = {
                "job_id": "20261104T142122-91b49519",
                "state": "failed",
                "yt_dlp_started": False,
                "artifacts": [],
                "staging_directory": str(work),
            }
            self.assertTrue(ytmusic._safe_skin_bones_retry(
                manifest, "PrlvpqvqK2c"
            ))
            (work / "unexpected.tmp").write_text("x")
            self.assertFalse(ytmusic._safe_skin_bones_retry(
                manifest, "PrlvpqvqK2c"
            ))


if __name__ == "__main__":
    unittest.main()
