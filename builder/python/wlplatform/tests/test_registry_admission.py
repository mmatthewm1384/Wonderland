import json

from wlplatform.registry.admission import RegistryAdmission


def test_registry_admission_accepts_certified_package(tmp_path):

    evidence = (
        tmp_path
        / "vault"
        / "08-Operations"
        / "evidence"
        / "registry-certification"
    )

    evidence.mkdir(
        parents=True
    )

    (
        evidence
        / "attestation.json"
    ).write_text(
        json.dumps(
            {
                "type":
                    "registry-attestation",
                "foundations": [
                    "trust-foundation-v1",
                    "identity-foundation-v1",
                    "runtime-foundation-v1",
                ],
            }
        )
    )

    package = (
        tmp_path
        / "scripts"
        / "auto-drop"
        / "packages"
        / "example-package-v1"
    )

    package.mkdir(
        parents=True
    )

    (
        package
        / "manifest.json"
    ).write_text(
        json.dumps(
            {
                "package":
                    "example-package-v1",
                "version":
                    "1.0.0",
            }
        )
    )

    result = RegistryAdmission(
        tmp_path
    ).admit(
        "example-package-v1"
    )

    assert result["status"] == "ADMITTED"
