import importlib.util
from pathlib import Path
import tempfile
import unittest

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


if __name__ == "__main__":
    unittest.main()
