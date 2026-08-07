from wlplatform.registry.validation import RegistryValidationService


def test_registry_validation_does_not_require_foundations(tmp_path):
    """
    Regression:

    Registry validation must not enforce foundation policy.

    Foundation requirements belong to certification.
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
        / "example-package-v1"
    )

    package.mkdir()

    (
        package
        / "manifest.json"
    ).write_text(
        """
        {
            "package": "example-package-v1",
            "version": "1.0.0",
            "category": "example"
        }
        """
    )

    result = RegistryValidationService(
        tmp_path
    ).validate()

    assert result["passed"] is True
    assert result["malformed_manifests"] == []
    assert result["duplicate_package_ids"] == []
    assert result["missing_manifests"] == []
