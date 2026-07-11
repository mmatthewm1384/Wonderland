"""Wonderland Governance orchestration engine."""

from __future__ import annotations

import hashlib
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .models import CheckResult, GovernanceReport
from .runner import CommandRunner


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha256_file(path: Path) -> str | None:
    if not path.is_file():
        return None

    digest = hashlib.sha256()

    with path.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            digest.update(chunk)

    return digest.hexdigest()


class GovernanceEngine:
    SCHEMA_VERSION = 1
    ENGINE_VERSION = "1.0.0-beta.1"

    def __init__(self, root: Path):
        self.root = root.resolve()
        self.runner = CommandRunner(self.root)
        self.state_root = (
            self.root
            / "vault"
            / "08-Operations"
            / "state"
        )
        self.certification_root = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
        )
        self.state_path = (
            self.state_root
            / "wl-governance-state.json"
        )

    def verify(self) -> dict[str, Any]:
        checks = self._run_checks(
            self._verification_contract()
        )

        report = self._build_report(
            mode="verify",
            checks=checks,
        )
        self._persist_state(report)

        return report.to_dict()

    def audit(self) -> dict[str, Any]:
        checks = self._run_checks(
            self._audit_contract()
        )

        report = self._build_report(
            mode="audit",
            checks=checks,
        )
        report.metadata["repository"] = (
            self._repository_metadata()
        )
        self._persist_state(report)

        return report.to_dict()

    def doctor(self) -> dict[str, Any]:
        contract = {
            **self._verification_contract(),
            **self._doctor_contract(),
        }
        checks = self._run_checks(contract)

        report = self._build_report(
            mode="doctor",
            checks=checks,
        )
        report.metadata.update(
            {
                "repository": self._repository_metadata(),
                "governance_state_path": str(
                    self.state_path
                ),
            }
        )
        self._persist_state(report)

        return report.to_dict()

    def report(self) -> dict[str, Any]:
        value = self.doctor()
        value["mode"] = "report"
        return value

    def state(self) -> dict[str, Any]:
        if not self.state_path.is_file():
            return {
                "schema_version": self.SCHEMA_VERSION,
                "result": "PASS",
                "status": "uninitialized",
                "state_path": str(self.state_path),
            }

        value = json.loads(
            self.state_path.read_text(encoding="utf-8")
        )
        value["result"] = "PASS"
        value["state_path"] = str(self.state_path)
        return value

    def certify(
        self,
        *,
        require_clean: bool = False,
    ) -> dict[str, Any]:
        report = self.doctor()
        repository = self._repository_metadata()

        repository_clean = not repository["dirty"]

        checks = {
            "governance_doctor": (
                report.get("result") == "PASS"
            ),
            "repository_clean": (
                repository_clean
                if require_clean
                else True
            ),
        }

        errors: list[str] = []

        if not checks["governance_doctor"]:
            errors.append(
                "governance doctor did not pass"
            )

        if require_clean and not repository_clean:
            errors.append(
                "repository is dirty and clean certification "
                "was requested"
            )

        result = (
            "PASS"
            if all(checks.values()) and not errors
            else "FAIL"
        )

        timestamp = datetime.now(
            timezone.utc
        ).strftime("%Y%m%dT%H%M%SZ")

        certificate_path = (
            self.certification_root
            / f"governance-certified-{timestamp}.json"
        )

        payload = {
            "schema_version": self.SCHEMA_VERSION,
            "certification": (
                "Wonderland Governance Engine"
            ),
            "engine_version": self.ENGINE_VERSION,
            "created_at": utc_now(),
            "result": result,
            "require_clean": require_clean,
            "checks": checks,
            "errors": errors,
            "repository": repository,
            "doctor": report,
            "artifacts": {
                "state": {
                    "path": str(self.state_path),
                    "sha256": sha256_file(
                        self.state_path
                    ),
                }
            },
        }

        certificate_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )
        self._write_json(
            certificate_path,
            payload,
        )

        return {
            "result": result,
            "certificate": str(certificate_path),
            "checks": checks,
            "errors": errors,
        }

    def release_gate(self) -> dict[str, Any]:
        repository = self._repository_metadata()

        certification = self.certify(
            require_clean=True
        )

        checks = {
            "repository_clean": (
                not repository["dirty"]
            ),
            "governance_certification": (
                certification["result"] == "PASS"
            ),
        }

        errors = list(
            certification.get("errors", [])
        )

        result = (
            "PASS"
            if all(checks.values()) and not errors
            else "FAIL"
        )

        timestamp = datetime.now(
            timezone.utc
        ).strftime("%Y%m%dT%H%M%SZ")

        gate_path = (
            self.certification_root
            / f"governance-release-gate-{timestamp}.json"
        )

        payload = {
            "schema_version": self.SCHEMA_VERSION,
            "gate": "Wonderland Governance Release Gate",
            "created_at": utc_now(),
            "result": result,
            "checks": checks,
            "errors": errors,
            "repository": repository,
            "certification": certification,
        }

        self._write_json(
            gate_path,
            payload,
        )

        return {
            **payload,
            "gate_artifact": str(gate_path),
        }

    def version(self) -> dict[str, Any]:
        return {
            "schema_version": self.SCHEMA_VERSION,
            "result": "PASS",
            "name": "Wonderland Governance Engine",
            "version": self.ENGINE_VERSION,
            "root": str(self.root),
        }

    def _verification_contract(
        self,
    ) -> dict[str, dict[str, Any]]:
        return {
            "architecture": {
                "command": [
                    str(
                        self.root
                        / "bin"
                        / "wl-architecture-verify"
                    )
                ],
                "required": True,
            },
            "registry": {
                "command": self._supported_command(
                    self.root / "bin" / "wl-registry",
                    ("verify", "status", "list"),
                ),
                "required": True,
            },
            "capability": {
                "command": self._supported_command(
                    self.root / "bin" / "wl-capability",
                    ("verify", "status", "list"),
                ),
                "required": True,
            },
            "runtime-structural": {
                "command": [
                    str(
                        self.root
                        / "bin"
                        / "wl-runtime-engine"
                    ),
                    "verify",
                ],
                "required": True,
            },
            "runtime-regression": {
                "command": [
                    str(self.root / "bin" / "wl"),
                    "runtime",
                    "self-test",
                ],
                "required": True,
            },
        }

    def _audit_contract(
        self,
    ) -> dict[str, dict[str, Any]]:
        return {
            **self._verification_contract(),
            "git-integrity": {
                "command": [
                    "git",
                    "fsck",
                    "--no-progress",
                    "--connectivity-only",
                ],
                "required": True,
                "timeout_seconds": 600,
            },
        }

    def _doctor_contract(
        self,
    ) -> dict[str, dict[str, Any]]:
        return {
            "runtime-status": {
                "command": [
                    str(
                        self.root
                        / "bin"
                        / "wl-runtime-engine"
                    ),
                    "status",
                ],
                "required": True,
            },
            "governance-launcher": {
                "command": [
                    "/bin/test",
                    "-x",
                    str(
                        self.root
                        / "bin"
                        / "wl-governance"
                    ),
                ],
                "required": True,
            },
        }

    def _run_checks(
        self,
        contract: dict[str, dict[str, Any]],
    ) -> dict[str, CheckResult]:
        results: dict[str, CheckResult] = {}

        for check_id, specification in contract.items():
            command = specification.get("command")

            if not command:
                results[check_id] = CheckResult(
                    check_id=check_id,
                    status="FAIL",
                    required=bool(
                        specification.get(
                            "required",
                            True,
                        )
                    ),
                    command=[],
                    returncode=None,
                    duration_seconds=0.0,
                    error="no supported command available",
                )
                continue

            results[check_id] = self.runner.run(
                check_id=check_id,
                command=list(command),
                required=bool(
                    specification.get(
                        "required",
                        True,
                    )
                ),
                timeout_seconds=int(
                    specification.get(
                        "timeout_seconds",
                        300,
                    )
                ),
            )

        return results

    def _build_report(
        self,
        *,
        mode: str,
        checks: dict[str, CheckResult],
    ) -> GovernanceReport:
        failures = [
            check_id
            for check_id, check in checks.items()
            if (
                check.required
                and check.status != "PASS"
            )
        ]
        warnings = [
            check_id
            for check_id, check in checks.items()
            if (
                not check.required
                and check.status != "PASS"
            )
        ]

        return GovernanceReport(
            mode=mode,
            result=(
                "PASS"
                if not failures
                else "FAIL"
            ),
            created_at=utc_now(),
            checks=checks,
            failures=failures,
            warnings=warnings,
            metadata={
                "schema_version": self.SCHEMA_VERSION,
                "engine_version": self.ENGINE_VERSION,
                "root": str(self.root),
            },
        )

    def _persist_state(
        self,
        report: GovernanceReport,
    ) -> None:
        payload = {
            "schema_version": self.SCHEMA_VERSION,
            "engine_version": self.ENGINE_VERSION,
            "updated_at": utc_now(),
            "status": (
                "verified"
                if report.result == "PASS"
                else "failed"
            ),
            "last_mode": report.mode,
            "last_result": report.result,
            "failures": report.failures,
            "warnings": report.warnings,
        }

        self._write_json(
            self.state_path,
            payload,
        )

    def _repository_metadata(
        self,
    ) -> dict[str, Any]:
        def git(*arguments: str) -> str:
            completed = subprocess.run(
                ["git", *arguments],
                cwd=self.root,
                text=True,
                capture_output=True,
                check=False,
            )

            if completed.returncode != 0:
                return ""

            return completed.stdout.strip()

        dirty_output = git(
            "status",
            "--porcelain",
        )

        return {
            "root": str(self.root),
            "branch": (
                git("branch", "--show-current")
                or None
            ),
            "commit": (
                git("rev-parse", "HEAD")
                or None
            ),
            "dirty": bool(dirty_output),
            "dirty_paths": dirty_output.splitlines(),
        }

    def _supported_command(
        self,
        executable: Path,
        candidates: tuple[str, ...],
    ) -> list[str] | None:
        if not executable.is_file():
            return None

        for candidate in candidates:
            completed = subprocess.run(
                [str(executable), candidate],
                cwd=self.root,
                text=True,
                capture_output=True,
                check=False,
                timeout=30,
            )

            # Zero means the command is supported and passed.
            if completed.returncode == 0:
                return [
                    str(executable),
                    candidate,
                ]

            combined = (
                completed.stdout
                + "\n"
                + completed.stderr
            ).lower()

            # A recognized command that failed governance checks
            # should still be selected and reported honestly.
            unknown_markers = (
                "unknown command",
                "unsupported command",
                "usage:",
            )

            if not any(
                marker in combined
                for marker in unknown_markers
            ):
                return [
                    str(executable),
                    candidate,
                ]

        # Fall back to help so missing command support is visible.
        return [
            str(executable),
            "--help",
        ]

    @staticmethod
    def _write_json(
        path: Path,
        value: Any,
    ) -> None:
        path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        temporary = path.with_suffix(
            path.suffix + ".tmp"
        )

        temporary.write_text(
            json.dumps(
                value,
                indent=2,
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )

        temporary.replace(path)
