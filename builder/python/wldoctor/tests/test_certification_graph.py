from pathlib import Path
import tempfile
import json
import unittest

from wldoctor.engine import DoctorEngine


class CertificationGraphTests(unittest.TestCase):

    def test_repository_certificate_graph(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)

            cert = root / ".state/repository"
            cert.mkdir(parents=True)

            (cert / "certificate.json").write_text(
                json.dumps(
                    {
                        "engine": "repository",
                        "certified": True
                    }
                ),
                encoding="utf-8",
            )

            graph = DoctorEngine(root).certification_graph()

            self.assertTrue(
                graph["systems"]["repository"]["certified"]
            )


if __name__ == "__main__":
    unittest.main()
