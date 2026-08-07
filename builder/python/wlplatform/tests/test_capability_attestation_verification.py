import json

from wlplatform.registry.capability_verification import (
    CapabilityAttestationVerifier,
)


def test_capability_attestation_verify(tmp_path):

    evidence = (
        tmp_path
        / "vault"
        / "08-Operations"
        / "evidence"
        / "capability-attestation"
    )

    evidence.mkdir(
        parents=True
    )

    registry = (
        tmp_path
        / "vault"
        / "08-Operations"
        / "evidence"
        / "registry-certification"
    )

    registry.mkdir(
        parents=True
    )


    (
        registry
        / "latest.json"
    ).write_text("{}")


    index = (
        tmp_path
        / "vault"
        / "05-Registry"
        / "auto-drop"
    )

    index.mkdir(
        parents=True
    )

    (
        index
        / "package-index.json"
    ).write_text("{}")


    (
        evidence
        / "latest.json"
    ).write_text(
        json.dumps(
            {
                "type":
                    "capability-attestation",

                "schema_version":
                    2,

                "subject": {
                    "package":
                        "trust-foundation-v1",

                    "capability":
                        "identity.read",
                },

                "authority": {
                    "registry_index_sha256":
                        "sha256:"
                        + "invalid",
                }
            }
        )
    )


    result = CapabilityAttestationVerifier(
        tmp_path
    ).verify()


    assert result["status"] == "INVALID"
