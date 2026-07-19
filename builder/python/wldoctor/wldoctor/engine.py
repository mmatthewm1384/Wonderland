from wlplatform.certificates import publish_certificate_pointer
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from .adapters.repository import RepositoryAdapter
from .evidence import CertificationEvidence
from .manifest import manifest
from .graph import EvidenceGraph, EvidenceNode


class DoctorEngine:
    def __init__(self, root: Path) -> None:
        self.root = root.resolve()

        self.adapters = {
            "repository": RepositoryAdapter(),
        }



    def write_certificate(self) -> dict:
        payload = self.doctor()

        artifact_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
        )

        artifact_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

        path = (
            artifact_dir
            / "doctor-certification.json"
        )

        certificate = {
            "certification":
                "Wonderland Doctor Engine 1.2",
            "engine":
                "doctor",
            "schema_version": 1,
            "status":
                payload.get("status"),
            "health_score":
                payload.get("health_score", 0),
            "certified":
                payload.get("certified", False),
            "systems":
                payload.get("certification", {}),
        }

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
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "doctor-certification.json"
        )

        if not path.exists():
            return {
                "engine": "doctor",
                "result": "FAIL",
                "certified": False,
                "reason": "certificate missing",
            }

        try:
            certificate = json.loads(
                path.read_text(
                    encoding="utf-8"
                )
            )

        except Exception as exc:
            return {
                "engine": "doctor",
                "result": "FAIL",
                "certified": False,
                "reason": str(exc),
            }

        certified = bool(
            certificate.get("certified")
        )

        return {
            "engine": "doctor",
            "result":
                "PASS"
                if certified
                else "FAIL",
            "certified": certified,
            "certificate": certificate,
        }

    def certification_graph(self) -> dict:
        return CertificationEvidence(self.root).discover()


    def graph(self) -> dict[str, Any]:
        systems: dict[str, Any] = {}

        for name, adapter in self.adapters.items():
            try:
                systems[name] = adapter.run(self.root)

            except Exception as exc:
                systems[name] = {
                    "schema_version": 1,
                    "engine": name,
                    "status": "FAIL",
                    "error": str(exc),
                    "certified": False,
                }

        failed = [
            name
            for name, system in systems.items()
            if system.get("status") != "PASS"
        ]

        evidence = self.certification_graph()

        graph = EvidenceGraph(self.root)

        for name, system in systems.items():
            graph.add_node(
                EvidenceNode(
                    id=name,
                    engine=name,
                    status=system.get(
                        "status",
                        "FAIL",
                    ),
                    certified=bool(
                        system.get(
                            "certified",
                            False,
                        )
                    ),
                )
            )

        return {
            "schema_version": 1,
            "engine": "wonderland-doctor-graph",
            "version": "1.3",
            "status": (
                "PASS"
                if not failed
                else "FAIL"
            ),
            "systems": systems,
            "evidence": evidence,
            "dag": graph.as_dict(),
            "failed": failed,
        }


    def doctor(self) -> dict[str, Any]:
        systems: dict[str, Any] = {}

        for name, adapter in self.adapters.items():
            try:
                systems[name] = adapter.run(self.root)

            except Exception as exc:
                systems[name] = {
                    "schema_version": 1,
                    "engine": name,
                    "status": "FAIL",
                    "error": str(exc),
                    "certified": False,
                }

        certification_systems: dict[str, Any] = {}

        for name, system in systems.items():
            certificate = system.get("certificate")

            if isinstance(certificate, dict):
                certification_systems[name] = {
                    "certified": bool(
                        certificate.get("certified", False)
                    ),
                    "verification": certificate.get(
                        "verification"
                    ),
                }
            else:
                certification_systems[name] = {
                    "certified": bool(
                        system.get("certified", False)
                    ),
                    "verification": system.get(
                        "verification"
                    ),
                }

        statuses = [
            item.get("status") == "PASS"
            for item in systems.values()
        ]

        status = "PASS" if all(statuses) else "FAIL"

        health_scores = [
            item.get("health", {}).get("score")
            for item in systems.values()
            if isinstance(item.get("health"), dict)
            and isinstance(
                item["health"].get("score"),
                int,
            )
        ]

        health_score = (
            sum(health_scores) // len(health_scores)
            if health_scores
            else 0
        )

        certified = all(
            item.get("certified", False)
            for item in certification_systems.values()
        )

        return {
            "schema_version": 1,
            "engine": "wonderland-doctor",
            "version": "1.2",
            "status": status,
            "health_score": health_score,
            "manifest": manifest(),
            "systems": systems,
            "certification": {
                "systems": certification_systems,
                "overall": certified,
            },
            "certified": (
                status == "PASS"
                and certified
            ),
        }
