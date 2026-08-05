from pathlib import Path
import json
from datetime import datetime, timezone
from .drift import RegistryDrift
from .dependency_graph import DependencyGraph
from .package_index import PackageIndex
from wlplatform.services.evidence_chain_service import EvidenceChainService
from .hash import RegistryHasher
from .validation import RegistryValidationService
from .lineage import RegistryLineage
from .chain import CertificateChain


class RegistryCertification:

    def __init__(self, root):

        self.root = Path(root)

        self.registry_index = (
            self.root /
            "vault" /
            "05-Registry" /
            "auto-drop" /
            "package-index.json"
        )

        self.cert_dir = (
            self.root /
            "vault" /
            "08-Operations" /
            "certifications" /
            "registry"
        )


    def certify(self):

        if not self.registry_index.exists():

            raise RuntimeError(
                "Registry index missing"
            )


        data = json.loads(
            self.registry_index.read_text()
        )


        validation = RegistryValidationService(
            self.root
        ).validate()


        if not validation["passed"]:

            raise RuntimeError(
                json.dumps(
                    {
                        "error":
                            "Registry validation failed",
                        "malformed_manifests":
                            validation[
                                "malformed_manifests"
                            ],
                        "duplicate_package_ids":
                            validation[
                                "duplicate_package_ids"
                            ],
                        "missing_manifests":
                            validation[
                                "missing_manifests"
                            ],
                    },
                    indent=2
                )
            )



        drift = RegistryDrift(
            data,
            self.registry_index,
        ).verify()


        graph_result = DependencyGraph(
            PackageIndex(self.root)
        ).verify_integrity()

        if not graph_result["passed"]:

            raise RuntimeError(
                json.dumps(
                    {
                        "error": "Registry graph validation failed",
                        "missing_dependencies":
                            graph_result["missing_dependencies"],
                        "dependency_cycles":
                            graph_result["dependency_cycles"],
                    },
                    indent=2
                )
            )

        if not drift.passed:

            raise RuntimeError(
                json.dumps(
                    {
                        "error": "Registry verification failed",
                        "missing_packages":
                            drift.missing_packages,
                        "orphaned_packages":
                            drift.orphaned_packages,
                        "changed_packages":
                            drift.changed_packages,
                        "malformed_manifests":
                            drift.malformed_manifests,
                        "missing_dependencies":
                            drift.missing_dependencies,
                        "dependency_cycles":
                            drift.dependency_cycles,
                    },
                    indent=2
                )
            )


        lineage = RegistryLineage(
            self.root
        ).create(
            {
                "validation":
                    validation,

                "graph":
                    graph_result,

                "drift":
                    {
                        "passed":
                            drift.passed
                    }
            }
        )



        registry_hash = (
            RegistryHasher.hash_model(
                data
            )
        )


        certificate = {
            "schema_version": 1,
            "artifact": "auto-drop-registry",
            "status": "CERTIFIED",
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat(),
            "packages": len(
                data.get(
                    "packages",
                    {}
                )
            ),
            "source": "manifest-derived",
            "registry_hash": registry_hash,
            "lineage": lineage
        }


        self.cert_dir.mkdir(
            parents=True,
            exist_ok=True
        )


        output = (
            self.cert_dir /
            "registry-certification.json"
        )


        chained = CertificateChain(
            self.root
        ).append(
            certificate
        )


        output.write_text(
            json.dumps(
                chained,
                indent=2
            )
        )


        return chained
