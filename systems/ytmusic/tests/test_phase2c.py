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


class Phase2CRecoveryUtilityEvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        module_path = (
            Path(__file__).resolve().parents[1]
            / "tools" / "recover_serotonin.py"
        )
        recovery_spec = importlib.util.spec_from_file_location(
            "ytmusic_recovery_phase2c_tests", module_path
        )
        cls.recovery = importlib.util.module_from_spec(recovery_spec)
        sys.modules[recovery_spec.name] = cls.recovery
        recovery_spec.loader.exec_module(cls.recovery)

    def fixture(self, directory):
        import hashlib
        import json
        from unittest.mock import patch

        r = self.recovery
        base = Path(directory)

        source = base / "approved-batch.json"
        source.write_text('{"approved":true}\n')

        job = base / "failed-job.json"
        job.write_text(json.dumps({
            "schema": "wonderland.ytmusic.job.v1",
            "job_id": "test-job",
            "kind": "track",
            "state": "verification_failed",
            "source_url": "https://www.youtube.com/watch?v=MtAsU2cGKxs",
            "artifacts": [],
        }))

        staged = base / "staged.m4a"
        staged.write_bytes(b"test-m4a-content")
        promoted = base / "promoted.m4a"
        promoted.write_bytes(b"test-m4a-content")

        info = {
            "id": "MtAsU2cGKxs",
            "title": "LaLion - SEROTONIN (Prod. LaLion)",
            "uploader": "LaLion",
        }
        staged_sidecar = base / "staged.info.json"
        staged_sidecar.write_text(json.dumps(info))
        promoted_sidecar = base / "promoted.info.json"
        promoted_sidecar.write_text(json.dumps(info))

        digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()

        values = {
            "BATCH_ID": "test-batch",
            "JOB_ID": "test-job",
            "VIDEO_ID": "MtAsU2cGKxs",
            "SCHEMA": "wonderland.ytmusic.recovery.v1",
            "EXPECTED_TITLE": "SEROTONIN",
            "EXPECTED_UPLOADER": "LaLion",
            "EXPECTED_SOURCE_SHA256": digest(source),
            "EXPECTED_JOB_SHA256": digest(job),
            "EXPECTED_MEDIA_SHA256": digest(staged),
        }

        patchers = [
            patch.object(r, key, value)
            for key, value in values.items()
        ]
        for p in patchers:
            p.start()
            self.addCleanup(p.stop)

        evidence = {
            "schema": values["SCHEMA"],
            "batch_id": values["BATCH_ID"],
            "video_id": values["VIDEO_ID"],
            "job_id": values["JOB_ID"],
            "source_manifest": str(source),
            "source_manifest_sha256": digest(source),
            "job_manifest": str(job),
            "job_manifest_sha256": digest(job),
            "staged_artifact": {
                "path": str(staged),
                "sha256": digest(staged),
                "sidecar": str(staged_sidecar),
            },
            "promoted_artifact": {
                "path": str(promoted),
                "sha256": digest(promoted),
            },
        }

        return {
            "source": source,
            "job": job,
            "staged": staged,
            "promoted": promoted,
            "staged_sidecar": staged_sidecar,
            "promoted_sidecar": promoted_sidecar,
            "evidence": evidence,
            "digest": digest,
        }

    def run_verifier(self, f):
        self.recovery.verify_evidence(
            f["evidence"],
            f["staged"],
            f["promoted"],
            f["source"],
            f["job"],
        )

    def test_valid_evidence_passes(self):
        import tempfile
        with tempfile.TemporaryDirectory() as td:
            f = self.fixture(td)
            self.run_verifier(f)

    def test_source_manifest_declaration_tampering_fails(self):
        import tempfile
        with tempfile.TemporaryDirectory() as td:
            f = self.fixture(td)
            f["evidence"]["source_manifest_sha256"] = "0" * 64
            with self.assertRaisesRegex(RuntimeError, "source manifest digest"):
                self.run_verifier(f)

    def test_original_job_state_tampering_fails(self):
        import json
        import tempfile
        with tempfile.TemporaryDirectory() as td:
            f = self.fixture(td)
            job = json.loads(f["job"].read_text())
            job["state"] = "completed"
            f["job"].write_text(json.dumps(job))
            new_digest = f["digest"](f["job"])
            self.recovery.EXPECTED_JOB_SHA256 = new_digest
            f["evidence"]["job_manifest_sha256"] = new_digest
            with self.assertRaisesRegex(RuntimeError, "identity/state"):
                self.run_verifier(f)

    def test_staged_artifact_tampering_fails(self):
        import tempfile
        with tempfile.TemporaryDirectory() as td:
            f = self.fixture(td)
            f["staged"].write_bytes(b"tampered")
            with self.assertRaisesRegex(RuntimeError, "Staged artifact"):
                self.run_verifier(f)

    def test_promoted_artifact_tampering_fails(self):
        import tempfile
        with tempfile.TemporaryDirectory() as td:
            f = self.fixture(td)
            f["promoted"].write_bytes(b"tampered")
            with self.assertRaisesRegex(RuntimeError, "Promoted artifact"):
                self.run_verifier(f)

    def test_staged_sidecar_identity_mismatch_fails(self):
        import json
        import tempfile
        with tempfile.TemporaryDirectory() as td:
            f = self.fixture(td)
            info = json.loads(f["staged_sidecar"].read_text())
            info["id"] = "wrong-video-id"
            f["staged_sidecar"].write_text(json.dumps(info))
            with self.assertRaisesRegex(RuntimeError, "video ID"):
                self.run_verifier(f)

    def test_symlinked_evidence_file_fails(self):
        import json
        import tempfile
        with tempfile.TemporaryDirectory() as td:
            f = self.fixture(td)
            evidence_file = Path(td) / "evidence.json"
            evidence_file.write_text(json.dumps(f["evidence"]))
            link = Path(td) / "evidence-link.json"
            link.symlink_to(evidence_file)

            with self.assertRaisesRegex(RuntimeError, "must not be a symlink"):
                self.recovery.verify_existing_evidence_file(
                    link,
                    f["staged"],
                    f["promoted"],
                    f["source"],
                    f["job"],
                )

    def test_missing_evidence_file_fails(self):
        import tempfile
        with tempfile.TemporaryDirectory() as td:
            f = self.fixture(td)
            missing = Path(td) / "missing.json"
            with self.assertRaisesRegex(RuntimeError, "regular file"):
                self.recovery.verify_existing_evidence_file(
                    missing,
                    f["staged"],
                    f["promoted"],
                    f["source"],
                    f["job"],
                )



if __name__ == "__main__":
    unittest.main()
