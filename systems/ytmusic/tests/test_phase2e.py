import hashlib
import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1] / "lib" / "ytmusic.py"
spec = importlib.util.spec_from_file_location("ytmusic_phase2e", MODULE)
ytmusic = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ytmusic)

ROOT = MODULE.parents[1]
APPROVED_SHA256 = (
    "d497d2eaf5a463b4d2fcfe9561f3a2f3a31cafc110fd81adc3c6749e0570f0e7"
)

CASES = {
    "debauchery": {
        "video_id": "LV8VTCCmonw",
        "title": "Debauchery",
        "position": 6,
        "job_id": "20261106T075429-a7252910",
        "job_sha256": "e84311bf448e024a7f5fe01fd602ca871ae84d2a7c6767a94f67f4d0fc1b831a",
        "job_file": "20261106T075429-a7252910.json",
        "disposition_file": "20261105-001.json",
        "disposition_sha256": "530efad0c085fafbb98540f8368d69934927670ff80f33c134cf95bdfd41e36d",
        "source_disposition": ROOT / "manifests/dispositions/20261105-001.json",
        "source_job": ROOT / "manifests/20261106T075429-a7252910.json",
    },
    "terrified": {
        "video_id": "j_VCJq1lrxw",
        "title": "Terrified",
        "position": 7,
        "job_id": "20261106T081528-d3ebfd49",
        "job_sha256": "fd739d2c5787797f999d00e016e260d481f985dbc36813ff6bc599d2d75988c0",
        "job_file": "20261106T081528-d3ebfd49.json",
        "disposition_file": "20261105-001-terrified.json",
        "disposition_sha256": "88d3665936a08e63f49d5fec70d46f8379b0d237861bd23ee974df11cb0f8c64",
        "source_disposition": ROOT / "manifests/dispositions/20261105-001-terrified.json",
        "source_job": ROOT / "manifests/20261106T081528-d3ebfd49.json",
    },
}


class Phase2EDispositionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.manifest_dir = Path(self.temp.name) / "manifests"
        (self.manifest_dir / "dispositions").mkdir(parents=True)
        self.cfg = {"manifest_dir": self.manifest_dir}
        self.document = {"batch_id": "20261105-001"}

    def tearDown(self):
        self.temp.cleanup()

    def prepare(self, key):
        case = CASES[key]
        shutil.copy2(
            case["source_disposition"],
            self.manifest_dir / "dispositions" / case["disposition_file"],
        )
        shutil.copy2(
            case["source_job"],
            self.manifest_dir / case["job_file"],
        )
        track = {
            "video_id": case["video_id"],
            "title": case["title"],
            "position": case["position"],
        }
        previous = {"state": "failed", "exit_code": 1}
        return case, track, previous

    def validate(self, track, previous):
        return ytmusic._batch_blocked_disposition(
            self.cfg, self.document, track, previous
        )

    def test_exact_debauchery_disposition_is_accepted(self):
        case, track, previous = self.prepare("debauchery")
        result = self.validate(track, previous)
        self.assertEqual(result["state"], "blocked_source_unavailable")
        self.assertEqual(result["job_manifest_sha256"], case["job_sha256"])
        self.assertEqual(result["disposition_sha256"], case["disposition_sha256"])

    def test_exact_terrified_disposition_is_accepted(self):
        case, track, previous = self.prepare("terrified")
        result = self.validate(track, previous)
        self.assertEqual(result["state"], "blocked_source_unavailable")
        self.assertEqual(result["job_manifest_sha256"], case["job_sha256"])
        self.assertEqual(result["disposition_sha256"], case["disposition_sha256"])

    def test_both_sources_reject_disposition_tampering(self):
        for key in CASES:
            with self.subTest(source=key):
                self.manifest_dir = Path(self.temp.name) / f"manifests-{key}"
                (self.manifest_dir / "dispositions").mkdir(parents=True)
                self.cfg = {"manifest_dir": self.manifest_dir}
                case, track, previous = self.prepare(key)
                path = self.manifest_dir / "dispositions" / case["disposition_file"]
                path.write_bytes(path.read_bytes() + b" ")
                with self.assertRaisesRegex(RuntimeError, "Disposition checksum"):
                    self.validate(track, previous)

    def test_both_sources_reject_job_tampering(self):
        for key in CASES:
            with self.subTest(source=key):
                self.manifest_dir = Path(self.temp.name) / f"job-manifests-{key}"
                (self.manifest_dir / "dispositions").mkdir(parents=True)
                self.cfg = {"manifest_dir": self.manifest_dir}
                case, track, previous = self.prepare(key)
                path = self.manifest_dir / case["job_file"]
                path.write_bytes(path.read_bytes() + b" ")
                with self.assertRaisesRegex(RuntimeError, "failed-job checksum"):
                    self.validate(track, previous)

    def test_unknown_source_cannot_use_either_disposition(self):
        case, track, previous = self.prepare("terrified")
        track["video_id"] = "6bGGnnPM0ok"
        self.assertIsNone(self.validate(track, previous))

    def test_blocked_record_is_revalidated_on_replay(self):
        case, track, previous = self.prepare("terrified")
        previous.update(
            state="blocked_source_unavailable",
            job_id=case["job_id"],
            job_manifest_sha256=case["job_sha256"],
        )
        result = self.validate(track, previous)
        self.assertEqual(result["state"], "blocked_source_unavailable")

    def test_blocked_record_with_wrong_job_is_rejected(self):
        self.prepare("terrified")
        previous = {
            "state": "blocked_source_unavailable",
            "exit_code": 1,
            "job_id": "unrelated-job",
            "job_manifest_sha256": "0" * 64,
        }
        with self.assertRaisesRegex(RuntimeError, "does not match pinned job"):
            self.validate(
                {
                    "video_id": CASES["terrified"]["video_id"],
                    "title": "Terrified",
                    "position": 7,
                },
                previous,
            )

    def test_wrong_previous_state_is_rejected(self):
        self.prepare("terrified")
        with self.assertRaisesRegex(RuntimeError, "previously failed"):
            self.validate(
                {
                    "video_id": CASES["terrified"]["video_id"],
                    "title": "Terrified",
                    "position": 7,
                },
                {"state": "completed", "exit_code": 1},
            )

    def test_ambiguous_historical_job_set_is_rejected(self):
        case, track, previous = self.prepare("terrified")
        shutil.copy2(
            self.manifest_dir / case["job_file"],
            self.manifest_dir / "duplicate-job.json",
        )
        with self.assertRaisesRegex(RuntimeError, "ambiguous"):
            self.validate(track, previous)


if __name__ == "__main__":
    unittest.main()
