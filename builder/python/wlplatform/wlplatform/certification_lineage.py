from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from .certification_registry import CertificationRegistry


class CertificationLineage:

    VERSION = 1

    def __init__(self, root: Path):
        self.root = root.resolve()

        self.engine_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "engines"
        )

        self.graph_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "graph"
        )


    def digest(self, path: Path) -> str:
        return hashlib.sha256(
            path.read_bytes()
        ).hexdigest()


    def build(self) -> dict:


        nodes = {}

        registry = CertificationRegistry(
            self.root
        )

        engines = registry.snapshot()

        for name, item in engines.items():

            artifact = item.get(
                "artifact"
            )

            digest = item.get(
                "digest"
            )

            certified = item.get(
                "certified",
                False,
            )

            if (
                not artifact
                or not digest
                or not certified
            ):
                continue

            nodes[name] = {
                "artifact": artifact,
                "digest": digest,
                "generated":
                    item.get(
                        "generated"
                    ),
                "certified": True,
                "dependencies": [],
            }



        graph = {
            "schema_version": 1,
            "lineage_version": self.VERSION,
            "generated":
                datetime.now(
                    timezone.utc
                ).isoformat(),
            "nodes": nodes,
        }

        self.graph_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

        output = (
            self.graph_dir
            / "certification-lineage.json"
        )

        output.write_text(
            json.dumps(
                graph,
                indent=2,
                sort_keys=True,
            ),
            encoding="utf-8",
        )

        return graph
