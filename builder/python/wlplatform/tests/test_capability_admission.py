import json

from wlplatform.registry.capability_admission import (
    CapabilityAdmission
)


def test_capability_granted(tmp_path):

    registry = (
        tmp_path
        / "vault"
        / "05-Registry"
    )

    registry.mkdir(
        parents=True
    )

    (
        registry
        / "capabilities.json"
    ).write_text(
        json.dumps(
            {
                "schema_version": 1,
                "capabilities": {
                    "example-package-v1": [
                        "artifact.read"
                    ]
                }
            }
        )
    )

    result = CapabilityAdmission(
        tmp_path
    ).request(
        "example-package-v1",
        "artifact.read",
    )

    assert result["type"] == "capability-attestation"
    
    assert result["schema_version"] == 2
    
    assert (
        result["subject"]["package"]
        == "example-package-v1"
    )
    
    assert (
        result["subject"]["capability"]
        == "artifact.read"
    )
    
    assert (
        result["decision"]["status"]
        == "GRANTED"
    )
    
    assert (
        result["authority"]
        is not None
    )
