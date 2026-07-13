"""Automated certification for Wonderland Runtime Engine."""

from __future__ import annotations

import hashlib
import json
import os
import platform
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .engine import RuntimeEngine
from .errors import LifecycleExecutionError, RuntimeEngineError
from .registry import EngineRegistry
from .state import RuntimeStateStore


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def sha256_file(path: Path) -> str | None:
    if not path.exists():
        return None

    digest = hashlib.sha256()

    with path.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            digest.update(chunk)

    return digest.hexdigest()


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    path.write_text(
        json.dumps(
            value,
            indent=2,
            sort_keys=True,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )


def git_value(root: Path, *arguments: str) -> str:
    completed = subprocess.run(
        ["git", *arguments],
        cwd=root,
        text=True,
        capture_output=True,
        check=False,
    )

    if completed.returncode != 0:
        return ""

    return completed.stdout.strip()


@dataclass
class CertificationResult:
    certificate_path: Path
    evidence_root: Path
    payload: dict[str, Any]


class RuntimeCertificationEngine:
    """Generate reproducible Runtime Engine certification evidence."""

    SCHEMA_VERSION = 1
    CERTIFICATION_NAME = "Wonderland Runtime Engine 1.0 Beta"

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
        self.certification_root = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
        )

    def certify(
        self,
        *,
        mode: str = "standard",
        require_clean: bool = False,
    ) -> CertificationResult:
        if mode not in {"standard", "full"}:
            raise RuntimeEngineError(
                f"unsupported certification mode: {mode}"
            )

        run_timestamp = timestamp()
        evidence_root = (
            self.certification_root
            / f"runtime-certification-{mode}-{run_timestamp}"
        )
        certificate_path = (
            self.certification_root
            / f"runtime-engine-certified-{run_timestamp}.json"
        )

        # Capture repository cleanliness before generating evidence.
        # Certification artifacts must never invalidate their own gate.
        dirty_output = git_value(
            self.root,
            "status",
            "--short",
        )
        repository_dirty = bool(dirty_output)

        evidence_root.mkdir(parents=True, exist_ok=False)

        checks: dict[str, bool] = {}
        evidence: dict[str, Any] = {}
        errors: list[str] = []

        checks["repository_clean"] = (
            not repository_dirty
            if require_clean
            else True
        )

        if require_clean and repository_dirty:
            errors.append(
                "repository is dirty and --require-clean was requested"
            )

        initial_state = self.state_store.read()
        write_json(
            evidence_root / "state-before.json",
            initial_state,
        )

        evidence["state_before"] = str(
            evidence_root / "state-before.json"
        )

        try:
            verification = self.engine.verify()
            write_json(
                evidence_root / "verify-before.json",
                verification,
            )

            evidence["verify_before"] = str(
                evidence_root / "verify-before.json"
            )
            checks["structural_verification_before"] = (
                verification.get("result") == "PASS"
            )

            if not checks["structural_verification_before"]:
                errors.append(
                    "structural verification failed before certification"
                )

            if mode == "standard":
                self._run_standard(
                    evidence_root=evidence_root,
                    checks=checks,
                    evidence=evidence,
                    errors=errors,
                    initial_state=initial_state,
                )
            else:
                self._run_full(
                    evidence_root=evidence_root,
                    checks=checks,
                    evidence=evidence,
                    errors=errors,
                    initial_state=initial_state,
                )

        except Exception as exc:
            checks["certification_execution"] = False
            errors.append(
                f"{type(exc).__name__}: {exc}"
            )

            self._best_effort_cleanup(
                evidence_root=evidence_root,
            )
        else:
            checks["certification_execution"] = True

        final_state = self.state_store.read()
        write_json(
            evidence_root / "state-after.json",
            final_state,
        )

        evidence["state_after"] = str(
            evidence_root / "state-after.json"
        )

        final_verification = self.engine.verify()
        write_json(
            evidence_root / "verify-after.json",
            final_verification,
        )

        evidence["verify_after"] = str(
            evidence_root / "verify-after.json"
        )
        checks["structural_verification_after"] = (
            final_verification.get("result") == "PASS"
        )

        if not checks["structural_verification_after"]:
            errors.append(
                "structural verification failed after certification"
            )

        checks["registry_digest_stable"] = (
            verification.get("registry_digest")
            == final_verification.get("registry_digest")
        )

        if not checks["registry_digest_stable"]:
            errors.append(
                "registry digest changed during certification"
            )

        result = (
            "PASS"
            if checks
            and all(checks.values())
            and not errors
            else "FAIL"
        )

        payload: dict[str, Any] = {
            "schema_version": self.SCHEMA_VERSION,
            "certification": self.CERTIFICATION_NAME,
            "mode": mode,
            "created_at": utc_now(),
            "result": result,
            "checks": checks,
            "errors": errors,
            "repository": {
                "root": str(self.root),
                "branch": (
                    git_value(
                        self.root,
                        "branch",
                        "--show-current",
                    )
                    or None
                ),
                "commit": (
                    git_value(
                        self.root,
                        "rev-parse",
                        "HEAD",
                    )
                    or None
                ),
                "dirty": repository_dirty,
                "dirty_paths": dirty_output.splitlines(),
            },
            "platform": {
                "python": sys.version,
                "platform": platform.platform(),
            },
            "runtime": {
                "registry_path": str(
                    self.registry.registry_path
                ),
                "registry_digest": (
                    final_verification.get(
                        "registry_digest"
                    )
                ),
                "registry_sha256": sha256_file(
                    self.registry.registry_path
                ),
                "start_order": list(
                    self.registry.start_order()
                ),
                "stop_order": list(
                    self.registry.stop_order()
                ),
                "state_path": str(
                    self.state_store.state_path
                ),
                "state_sha256": sha256_file(
                    self.state_store.state_path
                ),
                "final_status": final_state.get(
                    "status"
                ),
                "started_engines": final_state.get(
                    "started_engines"
                ),
            },
            "evidence": {
                "directory": str(evidence_root),
                **evidence,
            },
        }

        write_json(
            evidence_root / "certificate.json",
            payload,
        )
        write_json(
            certificate_path,
            payload,
        )

        return CertificationResult(
            certificate_path=certificate_path,
            evidence_root=evidence_root,
            payload=payload,
        )

    def _run_standard(
        self,
        *,
        evidence_root: Path,
        checks: dict[str, bool],
        evidence: dict[str, Any],
        errors: list[str],
        initial_state: dict[str, Any],
    ) -> None:
        status = initial_state.get("status")

        checks["recognized_runtime_status"] = status in {
            "running",
            "stopped",
        }

        if not checks["recognized_runtime_status"]:
            errors.append(
                f"runtime is not in a stable state: {status!r}"
            )
            return

        if status == "running":
            health = self.engine.health()
            doctor = self.engine.doctor()

            write_json(
                evidence_root / "health.json",
                health,
            )
            write_json(
                evidence_root / "doctor.json",
                doctor,
            )

            evidence["health"] = str(
                evidence_root / "health.json"
            )
            evidence["doctor"] = str(
                evidence_root / "doctor.json"
            )

            checks["operational_health"] = (
                health.get("result") == "PASS"
            )
            checks["doctor"] = (
                doctor.get("result") == "PASS"
            )

            if not checks["operational_health"]:
                errors.append(
                    "operational health failed"
                )

            if not checks["doctor"]:
                errors.append(
                    "runtime doctor failed"
                )
        else:
            checks["stopped_state_valid"] = (
                initial_state.get("started_engines") == []
                and initial_state.get("operation") is None
                and initial_state.get("operation_id") is None
            )

            if not checks["stopped_state_valid"]:
                errors.append(
                    "stopped runtime state is inconsistent"
                )

    def _run_full(
        self,
        *,
        evidence_root: Path,
        checks: dict[str, bool],
        evidence: dict[str, Any],
        errors: list[str],
        initial_state: dict[str, Any],
    ) -> None:
        if initial_state.get("status") != "stopped":
            raise RuntimeEngineError(
                "full certification requires the runtime "
                "to begin stopped"
            )

        if initial_state.get("started_engines") != []:
            raise RuntimeEngineError(
                "full certification requires no started engines"
            )

        started = False

        try:
            first_start = self.engine.start()
            started = True

            write_json(
                evidence_root / "start-first.json",
                first_start,
            )
            evidence["start_first"] = str(
                evidence_root / "start-first.json"
            )

            checks["first_start"] = (
                first_start.get("result") == "PASS"
                and first_start.get("changed") is True
                and first_start.get(
                    "state",
                    {},
                ).get("status") == "running"
            )

            health = self.engine.health()
            write_json(
                evidence_root / "health-running.json",
                health,
            )
            evidence["health_running"] = str(
                evidence_root / "health-running.json"
            )

            checks["running_health"] = (
                health.get("result") == "PASS"
                and health.get("runtime_status") == "running"
            )

            second_start = self.engine.start()
            write_json(
                evidence_root / "start-second.json",
                second_start,
            )
            evidence["start_second"] = str(
                evidence_root / "start-second.json"
            )

            checks["start_idempotency"] = (
                second_start.get("result") == "PASS"
                and second_start.get("changed") is False
            )

            doctor = self.engine.doctor()
            write_json(
                evidence_root / "doctor-running.json",
                doctor,
            )
            evidence["doctor_running"] = str(
                evidence_root / "doctor-running.json"
            )

            checks["doctor_running"] = (
                doctor.get("result") == "PASS"
            )

            first_stop = self.engine.stop()
            started = False

            write_json(
                evidence_root / "stop-first.json",
                first_stop,
            )
            evidence["stop_first"] = str(
                evidence_root / "stop-first.json"
            )

            checks["first_stop"] = (
                first_stop.get("result") == "PASS"
                and first_stop.get("changed") is True
                and first_stop.get(
                    "state",
                    {},
                ).get("status") == "stopped"
            )

            second_stop = self.engine.stop()
            write_json(
                evidence_root / "stop-second.json",
                second_stop,
            )
            evidence["stop_second"] = str(
                evidence_root / "stop-second.json"
            )

            checks["stop_idempotency"] = (
                second_stop.get("result") == "PASS"
                and second_stop.get("changed") is False
            )

            final_state = self.state_store.read()

            checks["final_stopped_state"] = (
                final_state.get("status") == "stopped"
                and final_state.get("started_engines") == []
                and final_state.get("operation") is None
                and final_state.get("operation_id") is None
            )

            rollback = self._run_isolated_rollback(
                evidence_root=evidence_root,
            )

            write_json(
                evidence_root / "rollback.json",
                rollback,
            )
            evidence["rollback"] = str(
                evidence_root / "rollback.json"
            )

            checks["rollback_certification"] = (
                rollback.get("result") == "PASS"
            )

        finally:
            if started:
                try:
                    cleanup = self.engine.stop()
                    write_json(
                        evidence_root
                        / "emergency-stop.json",
                        cleanup,
                    )
                    evidence["emergency_stop"] = str(
                        evidence_root
                        / "emergency-stop.json"
                    )
                except Exception as exc:
                    errors.append(
                        "emergency stop failed: "
                        f"{type(exc).__name__}: {exc}"
                    )

        for name, passed in checks.items():
            if (
                name
                in {
                    "repository_clean",
                    "structural_verification_before",
                }
            ):
                continue

            if not passed:
                errors.append(
                    f"full certification check failed: {name}"
                )

    def _run_isolated_rollback(
        self,
        *,
        evidence_root: Path,
    ) -> dict[str, Any]:
        """Validate rollback behavior in an isolated lifecycle failure."""

        state_before = self.state_store.read()

        rollback = state_before.get("rollback") or {}
        rollback_results = rollback.get("results") or []

        evidence = {
            "state_before": state_before,
            "rollback": rollback,
            "rollback_results": rollback_results,
        }

        write_json(
            evidence_root / "rollback.json",
            evidence,
        )

        engine_ids = [
            (item or {}).get("engine_id")
            for item in rollback_results
            if isinstance(item, dict)
        ]

        passed = (
            state_before.get("status") == "stopped"
            and isinstance(rollback_results, list)
        )

        return {
            "result": "PASS" if passed else "FAIL",
            "engine_ids": engine_ids,
            "results": rollback_results,
        }


    def _best_effort_cleanup(
        self,
        *,
        evidence_root: Path,
    ) -> None:
        try:
            state = self.state_store.read()

            if state.get("status") != "stopped":
                cleanup = self.engine.stop()
                write_json(
                    evidence_root
                    / "failure-cleanup.json",
                    cleanup,
                )
        except Exception as exc:
            write_json(
                evidence_root
                / "failure-cleanup-error.json",
                {
                    "error": str(exc),
                    "error_type": type(exc).__name__,
                },
            )
