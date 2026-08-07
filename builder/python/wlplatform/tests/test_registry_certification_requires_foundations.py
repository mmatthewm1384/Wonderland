from pathlib import Path
import json
import pytest

from wlplatform.registry.certification import RegistryCertification


def test_certification_requires_foundation_packages(tmp_path):
    """
    Regression:

    Certification must reject incomplete trusted registries.

    Registry validation checks structure.
    Certification verifies trust readiness.
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
        json.dumps(
            {
                "package": "example-package-v1",
                "version": "1.0.0",
                "category": "example",
                "type": "example",
                "dependencies": [],
            }
        )
    )

    registry_dir = (
        tmp_path
        / "vault"
        / "05-Registry"
        / "auto-drop"
    )

    registry_dir.mkdir(
        parents=True
    )

    (
        registry_dir
        / "package-index.json"
    ).write_text(
        json.dumps(
            {
                "schema_version": 1,
                "generated": True,
                "packages": {
                    "example-package-v1": {
                        "version": "1.0.0",
                        "type": "example",
                        "category": "example",
                        "dependencies": [],
                        "path": (
                            "scripts/auto-drop/"
                            "packages/example-package-v1"
                        ),
                    }
                },
            }
        )
    )

    with pytest.raises(RuntimeError):
        RegistryCertification(
            tmp_path
        ).certify()
