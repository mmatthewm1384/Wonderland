from __future__ import annotations

import hashlib
import json
from pathlib import Path
from datetime import datetime, timezone
from .certification_trust import CertificationTrustEvaluator


class PlatformCertificationEngine:
    VERSION = "1.0"

    def __init__(self, root: Path):
        self.root = root.resolve()

        self.certification_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "reports"
        )

    def _certificate_paths(self) -> dict[str, Path]:
        return {
            "runtime": (
                self.certification_dir
                / "runtime-certification.json"
            ),
            "repository": (
                self.certification_dir
                / "repository-certification.json"
            ),
            "doctor": (
                self.certification_dir
                / "doctor-certification.json"
            ),
            "builder": (
                self.certification_dir
                / "builder-certification.json"
            ),
            "governance": (
                self.certification_dir
                / "governance-certification.json"
            ),
        }

    def discover(self) -> dict:
        systems = {}

        for name, path in self._certificate_paths().items():
            if not path.exists():
                systems[name] = {
                    "certified": False,
                    "status": "MISSING",
                    "path": str(path),
                }
                continue

            try:
                payload = json.loads(
                    path.read_text(
                        encoding="utf-8"
                    )
                )

                systems[name] = {
                    "certified": bool(
                        payload.get("certified", False)
                    ),
                    "status": (
                        "PASS"
                        if payload.get("certified")
                        else "FAIL"
                    ),
                    "path": str(path),
                }

            except Exception as exc:
                systems[name] = {
                    "certified": False,
                    "status": "ERROR",
                    "error": str(exc),
                    "path": str(path),
                }

        return systems

    def state_digest(self, systems: dict) -> str:
        payload = json.dumps(
            systems,
            sort_keys=True,
            separators=(",", ":"),
        )

        return hashlib.sha256(
            payload.encode()
        ).hexdigest()

    def certify(self) -> dict:
        systems = self.discover()

        overall = all(
            item["certified"]
            for item in systems.values()
        )

        certificate = {
            "certification":
                "Wonderland Platform Engine 1.0",
            "engine":
                "platform",
            "version":
                self.VERSION,
            "schema_version": 1,
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat(),
            "systems":
                systems,
            "overall":
                "PASS"
                if overall
                else "FAIL",
            "certified":
                overall,
        }


        certificate["state_digest"] = (
            self.state_digest(systems)
        )

        trust = CertificationTrustEvaluator(
            self.root
        ).evaluate()

        certificate["trust"] = trust

        trust = CertificationTrustEvaluator(
            self.root
        ).evaluate()

        certificate["trust"] = trust

        lineage_path = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "graph"
            / "certification-lineage.json"
        )

        if lineage_path.exists():

            import hashlib

            lineage_digest = hashlib.sha256(
                lineage_path.read_bytes()
            ).hexdigest()

            certificate["lineage"] = {
                "artifact":
                    str(
                        lineage_path.relative_to(
                            self.root
                        )
                    ),
                "digest":
                    lineage_digest,
            }

        else:

            certificate["lineage"] = {
                "artifact":
                    "missing",
                "digest":
                    None,
            }


        certificate["trust_chain"] = {
            "schema_version": 1,
            "edges": [
                {
                    "source": "policy",
                    "target": "registry",
                    "relationship": "defines",
                },
                {
                    "source": "registry",
                    "target": "engine_evidence",
                    "relationship": "owns",
                },
                {
                    "source": "engine_evidence",
                    "target": "lineage",
                    "relationship": "proves",
                },
                {
                    "source": "lineage",
                    "target": "certification",
                    "relationship": "supports",
                },
            ],
        }

        trust = CertificationTrustEvaluator(
            self.root
        ).evaluate()

        certificate["trust"] = trust

        certificate["graph"] = {
            "artifact":
                "vault/08-Operations/certifications/graph/certification-graph.json"
        }

        self.certification_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

        path = (
            self.certification_dir
            / "platform-certification.json"
        )

        path.write_text(
            json.dumps(
                certificate,
                indent=2,
                sort_keys=True,
            ),
            encoding="utf-8",
        )

        certificate["artifact_path"] = str(path)

        return certificate

    def verify_certificate(self) -> dict:
        path = (
            self.certification_dir
            / "platform-certification.json"
        )

        if not path.exists():
            return {
                "engine": "platform",
                "result": "FAIL",
                "certified": False,
                "reason": "certificate missing",
            }

        payload = json.loads(
            path.read_text(
                encoding="utf-8"
            )
        )

        return {
            "engine": "platform",
            "result": (
                "PASS"
                if payload.get("certified")
                else "FAIL"
            ),
            "certified": bool(
                payload.get("certified")
            ),
            "state_digest": payload.get(
                "state_digest"
            ),
        }
