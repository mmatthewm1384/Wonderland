import json

from wlplatform.registry.registry_service import (
    RegistryService,
)


def test_registry_capabilities_graph(tmp_path):

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

    result = RegistryService(
        tmp_path
    ).capabilities()

    assert (
        "identity.read"
        in result["providers"]
    )
