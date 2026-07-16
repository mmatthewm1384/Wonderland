from pathlib import Path
import tempfile

from wlplatform.certification import certify


def test_certification_writes_under_root():

    with tempfile.TemporaryDirectory() as tmp:

        root = Path(tmp)

        artifact = certify(
            root=root
        )

        output = (
            root
            /
            "vault/08-Operations/certifications/platform-certification.json"
        )

        assert output.exists()

        assert artifact["certification"] == (
            "Wonderland Platform Certification"
        )


def test_certification_rejects_invalid_root():

    try:
        certify(root=Path("/"))
    except RuntimeError:
        return

    raise AssertionError(
        "Certification allowed filesystem root"
    )
