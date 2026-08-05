from pathlib import Path

from .registry_service import RegistryService


def verify_dependencies(
    root: Path,
    package: str,
) -> None:

    registry = RegistryService(root)

    for dependency in registry.dependencies(package):

        if not registry.installed(dependency):

            raise RuntimeError(
                f"Missing dependency: {dependency}"
            )

    print(
        "DEPENDENCY RESOLUTION PASS"
    )
