import json

from wlplatform.registry.capability_graph_validation import (
    CapabilityGraphValidator,
)


def test_capability_graph_validation_passes(tmp_path):

    package = (
        tmp_path
        / "scripts"
        / "auto-drop"
        / "packages"
        / "identity-foundation-v1"
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
                    "identity-foundation-v1",
                "provides": [
                    "identity.read"
                ],
                "requires": [],
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
                    "identity-foundation-v1": [
                        "identity.read"
                    ]
                },
            }
        )
    )

    result = CapabilityGraphValidator(
        tmp_path
    ).validate()

    assert result["passed"] is True
