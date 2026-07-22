#!/usr/bin/env python3

from pathlib import Path


class RegistryValidationError(Exception):
    pass


class RegistryValidationEngine:

    def __init__(self, root=None):

        self.root = (
            Path(root).resolve()
            if root
            else self.find_root()
        )

        self.registry = (
            self.root /
            "scripts/auto-drop/registry.yaml"
        )


    def find_root(self):

        path = Path(__file__).resolve()

        for parent in path.parents:

            if (
                parent.name == "Wonderland"
                and (parent / "scripts").exists()
                and (parent / "builder").exists()
            ):
                return parent

        raise RegistryValidationError(
            "Wonderland root not found"
        )


    def validate(self):

        if not self.registry.exists():
            raise RegistryValidationError(
                f"Missing registry: {self.registry}"
            )

        text = self.registry.read_text(
            encoding="utf-8"
        )

        checks = {
            "version": "version:",
            "artifacts": "artifacts:"
        }


        for name, value in checks.items():

            if value not in text:
                raise RegistryValidationError(
                    f"Missing {name}"
                )


        artifacts = []

        for line in text.splitlines():

            item = line.strip()

            if (
                line.startswith("  ")
                and item.endswith(":")
                and "/" in item
            ):
                artifacts.append(
                    item[:-1]
                )


        if not artifacts:
            raise RegistryValidationError(
                "No artifacts registered"
            )


        duplicates = [
            item
            for item in artifacts
            if artifacts.count(item) > 1
        ]


        if duplicates:
            raise RegistryValidationError(
                f"Duplicate artifacts: {duplicates}"
            )


        return {
            "certified": True,
            "root": str(self.root),
            "registry": str(self.registry),
            "artifact_count": len(artifacts),
            "artifacts": sorted(artifacts)
        }


if __name__ == "__main__":

    engine = RegistryValidationEngine()

    result = engine.validate()

    print("REGISTRY VALIDATION PASS")

    for key, value in result.items():
        print(f"{key}: {value}")
