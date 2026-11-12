import importlib.util
import shutil
import tempfile
import unittest
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1] / "lib" / "ytmusic.py"
spec = importlib.util.spec_from_file_location("ytmusic_phase2d", MODULE)
ytmusic = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ytmusic)

ROOT = MODULE.parents[1]
SOURCE_DISPOSITION = ROOT / "manifests/dispositions/20261105-001.json"
SOURCE_JOB = ROOT / "manifests/20261106T075429-a7252910.json"

DISPOSITION_SHA256 = "530efad0c085fafbb98540f8368d69934927670ff80f33c134cf95bdfd41e36d"
JOB_SHA256 = "e84311bf448e024a7f5fe01fd602ca871ae84d2a7c6767a94f67f4d0fc1b831a"


class Phase2DDispositionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.manifest_dir = Path(self.temp.name) / "manifests"
        (self.manifest_dir / "dispositions").mkdir(parents=True)

        shutil.copy2(
            SOURCE_DISPOSITION,
            self.manifest_dir / "dispositions/20261105-001.json",
        )
        shutil.copy2(
            SOURCE_JOB,
            self.manifest_dir / "20261106T075429-a7252910.json",
        )

        self.cfg = {"manifest_dir": self.manifest_dir}
        self.document = {"batch_id": "20261105-001"}
        self.track = {
            "video_id": "LV8VTCCmonw",
            "title": "Debauchery",
            "position": 6,
        }
        self.previous = {"state": "failed", "exit_code": 1}

    def tearDown(self):
        self.temp.cleanup()

    def validate(self):
        return ytmusic._batch_blocked_disposition(
            self.cfg, self.document, self.track, self.previous
        )

    def test_exact_disposition_is_accepted(self):
        result = self.validate()
        self.assertEqual(result["state"], "blocked_source_unavailable")
        self.assertEqual(result["job_manifest_sha256"], JOB_SHA256)
        self.assertEqual(result["disposition_sha256"], DISPOSITION_SHA256)

    def test_tampered_disposition_is_rejected(self):
        path = self.manifest_dir / "dispositions/20261105-001.json"
        path.write_bytes(path.read_bytes() + b" ")
        with self.assertRaisesRegex(RuntimeError, "Disposition checksum"):
            self.validate()

    def test_tampered_failed_job_is_rejected(self):
        path = self.manifest_dir / "20261106T075429-a7252910.json"
        path.write_bytes(path.read_bytes() + b" ")
        with self.assertRaisesRegex(RuntimeError, "failed-job checksum"):
            self.validate()

    def test_unrelated_video_cannot_use_disposition(self):
        self.track["video_id"] = "PrlvpqvqK2c"
        self.assertIsNone(self.validate())

    def test_ambiguous_historical_jobs_are_rejected(self):
        duplicate = self.manifest_dir / "second-job.json"
        shutil.copy2(
            self.manifest_dir / "20261106T075429-a7252910.json",
            duplicate,
        )
        with self.assertRaisesRegex(RuntimeError, "ambiguous"):
            self.validate()

    def test_non_failed_report_record_is_rejected(self):
        self.previous["state"] = "completed"
        with self.assertRaisesRegex(RuntimeError, "previously failed"):
            self.validate()


if __name__ == "__main__":
    unittest.main()
