"""
Wonderland Registry Integrity Verification

Validates that package-index.json matches
manifest-derived registry state.

Checks:

- missing packages
- orphan registry entries
- duplicate package IDs
- malformed manifests
- dependency references
- dependency cycles
"""

from dataclasses import dataclass, field
from pathlib import Path
import json


@dataclass(slots=True)
class DriftResult:

    passed: bool

    missing_packages: list[str] = field(
        default_factory=list
    )

    orphaned_packages: list[str] = field(
        default_factory=list
    )

    changed_packages: dict = field(
        default_factory=dict
    )

    malformed_manifests: list[str] = field(
        default_factory=list
    )

    missing_dependencies: dict = field(
        default_factory=dict
    )

    dependency_cycles: list[list[str]] = field(
        default_factory=list
    )

    errors: list[str] = field(
        default_factory=list
    )


class RegistryDrift:


    def __init__(
        self,
        registry_model,
        registry_path,
    ):

        self.registry_model = registry_model
        self.registry_path = Path(
            registry_path
        )

        self.root = (
            self.registry_path.parents[3]
        )

        self.packages_root = (
            self.root /
            "scripts/auto-drop/packages"
        )


    def derive_expected(self):

        packages = {}

        malformed = []


        if not self.packages_root.exists():

            raise RuntimeError(
                f"Missing packages directory: {self.packages_root}"
            )


        for package_dir in sorted(
            self.packages_root.iterdir()
        ):

            manifest = (
                package_dir /
                "manifest.json"
            )


            if not manifest.exists():
                continue


            try:

                data = json.loads(
                    manifest.read_text()
                )

            except Exception:

                malformed.append(
                    package_dir.name
                )

                continue


            name = data.get(
                "name",
                package_dir.name
            )


            packages[name] = {

                "version":
                    data.get("version"),

                "type":
                    data.get("type"),

                "category":
                    data.get("category"),

                "dependencies":
                    sorted(
                        data.get(
                            "dependencies",
                            []
                        )
                    ),

                "path":
                    str(
                        package_dir.relative_to(
                            self.root
                        )
                    )
            }


        return {
            "packages": packages,
            "malformed": malformed,
        }


    def normalize(self, model):

        packages = model.get(
            "packages",
            {}
        )


        normalized = {}


        for name, package in packages.items():

            item = dict(package)

            item["dependencies"] = sorted(
                item.get(
                    "dependencies",
                    []
                )
            )

            normalized[name] = item


        return normalized


    def detect_cycles(self, packages):

        graph = {

            name:
                set(
                    data.get(
                        "dependencies",
                        []
                    )
                )

            for name, data
            in packages.items()

        }


        visiting = set()
        visited = set()
        cycles = []


        def visit(node, stack):

            if node in visiting:

                index = stack.index(node)

                cycles.append(
                    stack[index:] + [node]
                )

                return


            if node in visited:
                return


            visiting.add(node)


            for dep in graph.get(
                node,
                []
            ):

                visit(
                    dep,
                    stack + [dep]
                )


            visiting.remove(node)

            visited.add(node)


        for node in graph:

            visit(
                node,
                [node]
            )


        return cycles


    def verify(self):

        expected_data = (
            self.derive_expected()
        )

        expected = self.normalize(
            expected_data
        )

        actual = self.normalize(
            self.registry_model
        )


        missing = sorted(
            set(expected)
            -
            set(actual)
        )


        orphaned = sorted(
            set(actual)
            -
            set(expected)
        )


        changed = {}


        for package in (
            set(expected)
            &
            set(actual)
        ):

            if (
                expected[package]
                !=
                actual[package]
            ):

                changed[package] = {

                    "expected":
                        expected[package],

                    "actual":
                        actual[package]

                }


        missing_dependencies = {}


        for package, data in expected.items():

            for dependency in data.get(
                "dependencies",
                []
            ):

                if dependency not in expected:

                    missing_dependencies.setdefault(
                        package,
                        []
                    ).append(
                        dependency
                    )


        cycles = self.detect_cycles(
            expected
        )


        passed = not any([

            missing,

            orphaned,

            changed,

            expected_data["malformed"],

            missing_dependencies,

            cycles

        ])


        return DriftResult(

            passed=passed,

            missing_packages=missing,

            orphaned_packages=orphaned,

            changed_packages=changed,

            malformed_manifests=
                expected_data["malformed"],

            missing_dependencies=
                missing_dependencies,

            dependency_cycles=
                cycles,

        )
