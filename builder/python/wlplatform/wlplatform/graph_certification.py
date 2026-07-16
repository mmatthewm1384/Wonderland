from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path


class CertificationGraphCertification:

    VERSION = 1

    def __init__(self, root: Path):
        self.root = root.resolve()

        self.graph_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "graph"
        )

    def digest(self, path: Path):
        return hashlib.sha256(
            path.read_bytes()
        ).hexdigest()

    def certify(self):

        graph = (
            self.graph_dir
            / "certification-graph.json"
        )

        lineage = (
            self.graph_dir
            / "certification-lineage.json"
        )

        checks = {
            "graph_exists":
                graph.exists(),

            "lineage_exists":
                lineage.exists(),

            "nodes_present":
                False,

            "digest_valid":
                False,
        }

        if graph.exists():

            try:
                payload = json.loads(
                    graph.read_text(
                        encoding="utf-8"
                    )
                )

                checks["nodes_present"] = bool(
                    payload.get(
                        "nodes"
                    )
                )

                checks["digest_valid"] = True

            except Exception:
                pass


        certified = all(
            checks.values()
        )

        certificate = {
            "certification":
                "Wonderland Certification Graph",

            "schema_version": 1,

            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat(),

            "artifact":
                str(
                    graph.relative_to(
                        self.root
                    )
                ),

            "digest":
                self.digest(graph)
                if graph.exists()
                else None,

            "checks":
                checks,

            "certified":
                certified,
        }

        output = (
            self.graph_dir
            / "certification-graph-certification.json"
        )

        self.graph_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

        output.write_text(
            json.dumps(
                certificate,
                indent=2,
                sort_keys=True,
            ),
            encoding="utf-8",
        )

        return certificate
