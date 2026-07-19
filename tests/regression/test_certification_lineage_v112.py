from pathlib import Path
import tempfile

from wlplatform.engine import PlatformCertificationEngine


def test_lineage_artifact_exists():

    with tempfile.TemporaryDirectory() as tmp:

        root = Path(tmp)

        engine = PlatformCertificationEngine(root)

        result = engine.certify()

        assert "artifact" in result
        assert result["status"] == "PASS"
