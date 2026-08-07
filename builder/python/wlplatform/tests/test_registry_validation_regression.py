import json

from wlplatform.registry.validation import RegistryValidationService


def test_registry_validation_ignores_non_manifest_directories(tmp_path):
    """
    Regression:

    Directories without manifest.json are not registry packages.

    Artifact/evidence/docs/lifecycle directories must not
    appear as missing manifests.
    """

    packages_root = (
        tmp_path
        / "scripts"
        / "auto-drop"
        / "packages"
    )

    packages_root.mkdir(
        parents=True
    )

    package = (
        packages_root
        / "trust-foundation-v1"
    )

    package.mkdir()

    (
        package
        / "manifest.json"
    ).write_text(
        json.dumps(
            {
                "package": "trust-foundation-v1",
                "version": "1.0.0",
                "category": "foundation",
            }
        )
    )

    artifact_only = (
        packages_root
        / "oblivion-foundation-v1"
    )

    artifact_only.mkdir()

    (
        artifact_only
        / "evidence"
    ).mkdir()

    result = RegistryValidationService(
        tmp_path
    ).validate()

    assert result["passed"] is True
    assert result["malformed_manifests"] == []
    assert result["duplicate_package_ids"] == []
    assert result["missing_manifests"] == []
