from pathlib import Path
import json

from .package_index import PackageIndex
from .dependency_graph import DependencyGraph
from .certification import RegistryCertification
from .hash import RegistryHasher
from .snapshot import RegistrySnapshot
from .restore_certification import RestoreCertification
from .certificate_verify import RegistryCertificateVerifier
from .chain import CertificateChain
from .validation import RegistryValidationService
from .drift import RegistryDrift


class RegistryService:

    def __init__(self, root):

        self.root = Path(root)

        self.index = PackageIndex(
            self.root
        )

        self.graph_engine = DependencyGraph(
            self.index
        )


    def package_path(self, package):

        return (
            self.root /
            "scripts/auto-drop/packages" 
        )


    def dependencies(self, package):

        manifest = (
            self.package_path(package) /
            "manifest.json"
        )

        if not manifest.exists():
            return []

        data = json.loads(
            manifest.read_text()
        )

        return data.get(
            "dependencies",
            []
        )


    def verify_dependencies(self, package):

        missing = []

        for dependency in self.dependencies(package):

            if not self.installed(dependency):
                missing.append(
                    dependency
                )

        if missing:
            raise RuntimeError(
                f"Missing dependencies: {missing}"
            )

        return {
            "status": "PASS",
            "package": package,
            "dependencies": self.dependencies(package),
        }


    def installed(self, package):

        return self.package_path(
            package
        ).exists()


    def rebuild(self):

        packages = {}

        packages_root = (
             self.root /
            "scripts/auto-drop/packages"
        )

        if packages_root.exists():

            for package_dir in sorted(
                packages_root.iterdir()
            ):

                manifest = (
                    package_dir /
                    "manifest.json"
                )

                if not manifest.exists():
                    continue

                data = json.loads(
                    manifest.read_text()
                )

                name = data.get(
                    "name",
                    package_dir.name
                )

                packages[name] = {
                    "version": data.get("version"),
                    "type": data.get("type"),
                    "category": data.get("category"),
                    "dependencies": data.get(
                        "dependencies",
                        []
                    ),
                    "path": str(
                        package_dir.relative_to(
                            self.root
                        )
                    )
                }


        registry = {
            "schema_version": 1,
            "generated": True,
            "packages": packages
        }

        self.index.save(
            registry
        )

        return {
            "status": "PASS",
            "packages": len(packages),
        }





    def verify_drift(self):

        registry = self.index.load()

        return RegistryDrift(
            registry,
            self.index.path,
        ).verify()





    def validate(self):

        return RegistryValidationService(
            self.root
        ).validate()


    def verify_graph(self):

        return self.graph_engine.verify_integrity()


    def verify_chain(self):

        return CertificateChain(
            self.root
        ).verify()



    def registry_hash(self):

        registry = self.index.load()

        return {
            "status": "PASS",
            "packages": len(
                registry.get(
                    "packages",
                    {}
                )
            ),
            "registry_hash":
                RegistryHasher.hash_model(
                    registry
                )
        }



    def verify_hash(self):

        registry = self.index.load()

        expected = (
            RegistryHasher.hash_model(
                registry
            )
        )

        actual = (
            RegistryHasher.hash_registry(
                self.index.path
            )
        )

        return {
            "passed":
                expected == actual,

            "expected_hash":
                expected,

            "registry_hash":
                actual
        }



    def verify_certificate(self):

        return RegistryCertificateVerifier(
            self.root
        ).verify()



    def snapshot(self):

        return RegistrySnapshot(
            self.root
        ).create()



    def restore(self, snapshot):

        from .snapshot_service import RegistrySnapshotService

        return RegistrySnapshotService(
            self.root
        ).restore(
            snapshot
        )



    def certify_restore(self):

        return RestoreCertification(
            self.root
        ).certify()



    def certify(self):

        return RegistryCertification(
            self.root
        ).certify()




    def graph(self):

        return self.graph_engine.build()


    def tree(self, package):

        return self.graph_engine.tree(
            package
        )


    def dependents(self, package):

        return self.graph_engine.dependents(
            package
        )


    def inspect(self, package):

        path = self.package_path(
            package
        )

        manifest = path / "manifest.json"

        if not manifest.exists():

            return {
                "status": "FAIL",
                "package": package,
                "reason": "manifest missing",
            }


        data = json.loads(
            manifest.read_text()
        )

        return {
            "status": "PASS",
            "package": package,
            "manifest": data,
        }
