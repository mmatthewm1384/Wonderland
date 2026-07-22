from __future__ import annotations

import json
from pathlib import Path

from .certification_registry import CertificationRegistry


class CertificationState:

    VERSION = 1

    def __init__(self, root: Path):
        self.root = root.resolve()

    def collect(self):

        registry = CertificationRegistry(
            self.root
        )

        active = registry.normalize_active()

        platform = {}

        platform_cert = (
            self.root
            / "vault/08-Operations/certifications/normalized/platform-certification.json"
        )

        if platform_cert.exists():
            data = json.loads(
                platform_cert.read_text()
            )

            platform = {
                "certified": data.get(
                    "certified",
                    False
                ),
                "state": data.get(
                    "overall",
                    "UNKNOWN"
                ),
                "digest": data.get(
                    "state_digest"
                )
            }


        graph = {
            "certified": False,
            "checks": {}
        }

        graph_cert = (
            self.root
            / "vault/08-Operations/certifications/graph/certification-graph-certification.json"
        )

        if graph_cert.exists():
            graph = json.loads(
                graph_cert.read_text()
            )


        required_engines = [
            "architecture",
            "builder",
            "governance",
            "registry",
            "repository",
            "runtime",
            "academy",
            "mirror",
        ]

        missing = [
            x
            for x in required_engines
            if x not in active
        ]

        trust = {
            "schema_version": 1,
            "certified": len(missing) == 0,
            "trust": (
                "COMPLETE"
                if not missing
                else "INCOMPLETE"
            ),
            "missing": missing,
            "checks": {
                "required_engines_complete":
                    len(missing) == 0,
                "evidence_present":
                    bool(active),
                "digests_present":
                    all(
                        e.get("digest")
                        for e in active.values()
                    ),
            }
        }


        return {
            "schema_version": self.VERSION,
            "platform": platform,
            "engines": {
                name: {
                    **data,
                    "status": (
                        data.get("status")
                        or (
                            "PASS"
                            if data.get("certified")
                            else "FAIL"
                        )
                    ),
                }
                for name, data in active.items()
            },
            "trust": trust,
            "graph": graph,
        }
