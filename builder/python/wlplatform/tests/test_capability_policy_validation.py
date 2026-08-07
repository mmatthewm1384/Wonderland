import json

from wlplatform.registry.capability_validation import (
    CapabilityPolicyValidator,
)


def test_capability_policy_validation_passes(tmp_path):

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
                    "example-package-v1"
            }
        )
    )

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
                    ],
                },
            }
        )
    )

    result = CapabilityPolicyValidator(
        tmp_path
    ).validate()

    assert result["passed"] is True
