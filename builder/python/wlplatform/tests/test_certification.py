from pathlib import Path
import tempfile
import json

import sys

sys.path.insert(
    0,
    str(Path(__file__).parents[1])
)

from wlplatform.certification import (
    CertificationError,
    PlatformCertificationEngine,
    certify,
)


class FakeContext:
    def __init__(self, root):
        self.root = root


class FakeController:
    def __init__(self, root):
        self.context = FakeContext(root)


def test_controller_root_resolution():
    with tempfile.TemporaryDirectory() as tmp:
        controller = FakeController(Path(tmp))

        result = certify(controller)

        assert "artifact" in result
        assert result["certification"] == (
            "Wonderland Platform Certification"
        )


def test_artifact_created():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)

        engine = PlatformCertificationEngine(root)
        result = engine.certify()

        artifact = Path(result["artifact"])

        assert artifact.exists()

        payload = json.loads(
            artifact.read_text()
        )

        assert payload["schema_version"] == 1
        assert "state_digest" in payload


def test_missing_controller():
    try:
        certify(None)
    except CertificationError:
        return

    raise AssertionError(
        "Expected CertificationError"
    )
