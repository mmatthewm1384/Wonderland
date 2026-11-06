import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

MODULE = Path(__file__).resolve().parents[1] / "lib" / "ytmusic.py"
spec = importlib.util.spec_from_file_location("ytmusic", MODULE)
ytmusic = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ytmusic)


class CoreTests(unittest.TestCase):
    def test_safe_stem_removes_path_and_control_chars(self):
        result = ytmusic.safe_stem('../A/B:\x00 Song ', 240)
        self.assertNotIn("/", result)
        self.assertNotIn("\x00", result)
        self.assertTrue(result)

    def test_sha256_known_value(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "sample"
            p.write_bytes(b"abc")
            self.assertEqual(
                ytmusic.sha256(p),
                "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
            )

    def test_atomic_json_roundtrip(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "x.json"
            ytmusic.write_json_atomic(p, {"state": "ok"})
            self.assertEqual(__import__("json").loads(p.read_text()), {"state": "ok"})


    def test_channel_url_rejected_for_track(self):
        with self.assertRaises(ValueError):
            ytmusic.validate_track_url(
                "https://www.youtube.com/@akidcalledghost"
            )

    def test_topic_channel_url_rejected(self):
        with self.assertRaises(ValueError):
            ytmusic.validate_track_url(
                "https://www.youtube.com/channel/UCibP9YTInIwO7idEGjXm0-g"
            )

    def test_direct_video_url_accepted(self):
        ytmusic.validate_track_url(
            "https://www.youtube.com/watch?v=abcdefghijk"
        )

    def test_partial_files_excluded(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            (root / "complete.webm").write_bytes(b"audio")
            (root / "partial.webm.part").write_bytes(b"partial")
            (root / "thumbnail.webp").write_bytes(b"image")
            (root / "metadata.info.json").write_text("{}")
            self.assertEqual(
                [p.name for p in ytmusic.media_candidates(root)],
                ["complete.webm"],
            )


    def test_m4a_acquisition_candidates_exclude_other_formats(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            (root / "canonical.m4a").write_bytes(b"m4a")
            (root / "legacy.webm").write_bytes(b"webm")
            (root / "legacy.mp3").write_bytes(b"mp3")
            (root / "partial.m4a.part").write_bytes(b"partial")
            self.assertEqual(
                [p.name for p in ytmusic.media_candidates(root, {".m4a"})],
                ["canonical.m4a"],
            )

    def test_legacy_candidate_selection_remains_format_tolerant(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            (root / "legacy.webm").write_bytes(b"webm")
            (root / "canonical.m4a").write_bytes(b"m4a")
            self.assertEqual(
                {p.suffix for p in ytmusic.media_candidates(root)},
                {".webm", ".m4a"},
            )

    def test_probe_rejects_non_m4a_when_required(self):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "audio.webm"
            path.write_bytes(b"audio")
            with self.assertRaisesRegex(RuntimeError, "non-M4A"):
                ytmusic.probe(path, require_m4a=True)

    def test_probe_accepts_m4a_container_when_required(self):
        import json

        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "audio.m4a"
            path.write_bytes(b"audio")
            payload = {
                "format": {
                    "format_name": "mov,mp4,m4a,3gp,3g2,mj2",
                    "duration": "10.0",
                    "size": "100",
                    "tags": {},
                },
                "streams": [
                    {
                        "codec_type": "audio",
                        "codec_name": "aac",
                        "sample_rate": "44100",
                        "channels": 2,
                    }
                ],
            }
            result = type("ProbeResult", (), {
                "stdout": json.dumps(payload)
            })()
            with patch.object(ytmusic, "tool_path", return_value="ffprobe"), \
                 patch.object(ytmusic.subprocess, "run", return_value=result):
                info = ytmusic.probe(path, require_m4a=True)
            self.assertIn("m4a", info["format_name"].split(","))

    def test_probe_rejects_wrong_container_with_m4a_extension(self):
        import json

        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "mislabelled.m4a"
            path.write_bytes(b"audio")
            payload = {
                "format": {
                    "format_name": "matroska,webm",
                    "duration": "10.0",
                    "size": "100",
                    "tags": {},
                },
                "streams": [
                    {"codec_type": "audio", "codec_name": "opus"}
                ],
            }
            result = type("ProbeResult", (), {
                "stdout": json.dumps(payload)
            })()
            with patch.object(ytmusic, "tool_path", return_value="ffprobe"), \
                 patch.object(ytmusic.subprocess, "run", return_value=result):
                with self.assertRaisesRegex(RuntimeError, "Expected M4A"):
                    ytmusic.probe(path, require_m4a=True)


if __name__ == "__main__":
    unittest.main()
