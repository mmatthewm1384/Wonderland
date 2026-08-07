import json

from wlplatform.registry.registry_service import RegistryService


def test_registry_verification_requires_certified_evidence(tmp_path):
    """
    Regression:

    Verification must fail when certification evidence
    does not exist.
    """

    service = RegistryService(tmp_path)

    try:
        service.verify()
        assert False, "Expected verification failure"
    except RuntimeError as exc:
        assert (
            "certification evidence missing"
            in str(exc)
        )


def test_registry_verification_accepts_certified_registry(tmp_path):
    """
    Regression:

    A certified registry must be verifiable without mutation.
    """

    evidence_dir = (
        tmp_path
        / "vault"
        / "08-Operations"
        / "evidence"
        / "registry-certification"
    )

    evidence_dir.mkdir(
        parents=True
    )

    certificate = {
        "schema_version": 1,
        "type": "registry-certification",
        "status": "CERTIFIED",
        "packages": 71,
        "foundations": [
            "trust-foundation-v1",
            "identity-foundation-v1",
            "runtime-foundation-v1",
        ],
    }

    certificate_path = (
        evidence_dir
        / "latest.json"
    )

    certificate_path.write_text(
        json.dumps(
            certificate,
            indent=2,
        )
    )

    import hashlib

    digest = hashlib.sha256(
        certificate_path.read_bytes()
    ).hexdigest()

    (
        evidence_dir
        / "latest.sha256"
    ).write_text(
        f"sha256:{digest}"
    )

    packages_root = (
        tmp_path
        / "scripts"
        / "auto-drop"
        / "packages"
    )

    for package in [
        "trust-foundation-v1",
        "identity-foundation-v1",
        "runtime-foundation-v1",
    ]:
        package_dir = (
            packages_root
            / package
        )

        package_dir.mkdir(
            parents=True
        )

        (
            package_dir
            / "manifest.json"
        ).write_text(
            json.dumps(
                {
                    "package": package,
                    "version": "1.0.0",
                    "category": "foundation",
                }
            )
        )

    result = RegistryService(
        tmp_path
    ).verify()

    assert result["status"] == "VERIFIED"
    assert result["registry"] == "valid"
    assert result["packages"] == 71
