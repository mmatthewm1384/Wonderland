"""RC1 release gate for Wonderland Runtime Engine."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .certification import RuntimeCertificationEngine
from .engine import RuntimeEngine
from .registry import EngineRegistry
from .regression import run_regression_suite
from .state import RuntimeStateStore


def utc_timestamp() -> str:
    return datetime.now(
        timezone.utc
    ).strftime("%Y%m%dT%H%M%SZ")


def write_json(
    path: Path,
    value: Any,
) -> None:
    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    path.write_text(
        json.dumps(
            value,
            indent=2,
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )


class RuntimeReleaseGate:
    """Run regression and certification as one release boundary."""

    def __init__(
        self,
        *,
        root: Path,
        registry: EngineRegistry,
        state_store: RuntimeStateStore,
        engine: RuntimeEngine,
    ):
        self.root = root.resolve()
        self.registry = registry
        self.state_store = state_store
        self.engine = engine

    def run(
        self,
        *,
        require_clean: bool = True,
    ) -> dict[str, Any]:
        timestamp = utc_timestamp()
        evidence_root = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / f"runtime-rc1-gate-{timestamp}"
        )

        evidence_root.mkdir(
            parents=True,
            exist_ok=False,
        )

        regression = run_regression_suite(
            verbosity=2
        )

        write_json(
            evidence_root / "regression.json",
            regression,
        )

        checks: dict[str, bool] = {
            "regression": (
                regression["result"] == "PASS"
            )
        }
        errors: list[str] = []

        if not checks["regression"]:
            errors.append(
                "isolated Runtime Engine regression failed"
            )

        certification_summary: dict[str, Any] | None = None

        if checks["regression"]:
            certification = RuntimeCertificationEngine(
                root=self.root,
                registry=self.registry,
                state_store=self.state_store,
                engine=self.engine,
            ).certify(
                mode="full",
                require_clean=require_clean,
            )

            certification_summary = {
                "result": certification.payload[
                    "result"
                ],
                "certificate": str(
                    certification.certificate_path
                ),
                "evidence": str(
                    certification.evidence_root
                ),
                "checks": certification.payload[
                    "checks"
                ],
                "errors": certification.payload[
                    "errors"
                ],
            }

            write_json(
                evidence_root
                / "full-certification.json",
                certification_summary,
            )

            checks["full_certification"] = (
                certification.payload["result"]
                == "PASS"
            )

            if not checks["full_certification"]:
                errors.extend(
                    certification.payload["errors"]
                )
        else:
            checks["full_certification"] = False

        result = (
            "PASS"
            if all(checks.values())
            and not errors
            else "FAIL"
        )

        payload = {
            "schema_version": 1,
            "gate": (
                "Wonderland Runtime Engine "
                "1.0 RC1"
            ),
            "created_at": datetime.now(
                timezone.utc
            ).isoformat(),
            "result": result,
            "require_clean": require_clean,
            "checks": checks,
            "errors": errors,
            "regression": regression,
            "certification": certification_summary,
            "evidence": str(evidence_root),
        }

        write_json(
            evidence_root / "release-gate.json",
            payload,
        )

        gate_path = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / f"runtime-rc1-gate-{timestamp}.json"
        )

        write_json(
            gate_path,
            payload,
        )

        payload["gate_artifact"] = str(
            gate_path
        )

        return payload
