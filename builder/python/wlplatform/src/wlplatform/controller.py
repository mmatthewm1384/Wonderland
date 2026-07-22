from __future__ import annotations

import time
from collections.abc import Callable

from .version import __version__
from .context import PlatformContext
from .certification_state import CertificationState
from .manifest_adapter import verify_manifests
from .registry_adapter import verify_registry
from .result import (
    CheckResult,
    PlatformReport,
    Status,
    aggregate_status,
)
from .subprocess_adapter import CommandSpec, run_command
from .engine_router import EngineRouter


Check = Callable[[PlatformContext], CheckResult]




def _verify_certification(context):

    state = CertificationState(
        context.root
    ).collect()

    platform = state.get(
        "platform",
        {}
    )

    certified = (
        platform.get("certified") is True
        and platform.get("state") == "PASS"
    )

    return CheckResult(
        name="certification",
        status=(
            Status.PASS
            if certified
            else Status.FAIL
        ),
        summary=(
            "certification state PASS"
            if certified
            else "certification state FAIL"
        ),
        details=state,
    )



def verify_certification(context):

    state = CertificationState(
        context.root
    ).collect()

    platform = state.get(
        "platform",
        {}
    )

    certified = (
        platform.get("certified") is True
        and platform.get("state") == "PASS"
    )

    return CheckResult(
        name="certification",
        status=(
            Status.PASS
            if certified
            else Status.FAIL
        ),
        summary=(
            "platform certification PASS"
            if certified
            else "platform certification FAIL"
        ),
        details={
            "platform": platform,
            "trust": state.get("trust", {}),
        },
    )



class PlatformController:
    def __init__(
        self,
        context: PlatformContext | None = None,
    ) -> None:
        self.context = context or PlatformContext.discover()

    def _core_checks(self) -> tuple[Check, ...]:

        def certification_check(
            context: PlatformContext,
        ) -> CheckResult:

            state = CertificationState(
                context.root
            ).collect()

            engines = state.get(
                "engines",
                {}
            )

            failures = [
                name
                for name, data in engines.items()
                if data.get("status") != "PASS"
            ]

            if failures:
                return CheckResult(
                    name="certification",
                    status=Status.FAIL,
                    summary=(
                        "failed certifications: "
                        + ", ".join(failures)
                    ),
                )

            return CheckResult(
                name="certification",
                status=Status.PASS,
                summary="all certification artifacts passed",
            )

        return (
            verify_registry,
            certification_check,
            verify_manifests,
        )

    def _optional_checks(self) -> tuple[Check, ...]:
        return ()

    def verify(
        self,
        *,
        include_optional: bool = False,
    ) -> PlatformReport:
        started = time.monotonic()

        checks = [
            check(self.context)
            for check in self._core_checks()
        ]

        if include_optional:
            checks.extend(
                check(self.context)
                for check in self._optional_checks()
            )

        prerequisite_failures = [
            check.name
            for check in checks
            if check.failed
        ]

        prerequisite_warnings = [
            check.name
            for check in checks
            if check.status is Status.WARN
        ]

        if prerequisite_failures:
            gate_status = Status.FAIL
            gate_summary = (
                "failed dependencies: "
                + ", ".join(prerequisite_failures)
            )
        elif prerequisite_warnings:
            gate_status = Status.WARN
            gate_summary = (
                "warning dependencies: "
                + ", ".join(prerequisite_warnings)
            )
        else:
            gate_status = Status.PASS
            gate_summary = (
                "all Platform engineering dependencies passed"
            )

        checks.append(
            CheckResult(
                name="engineering_gate",
                status=gate_status,
                summary=gate_summary,
            )
        )

        checks_tuple = tuple(checks)

        return PlatformReport(
            schema_version=1,
            engine_version=__version__,
            root=str(self.context.root),
            result=aggregate_status(checks_tuple),
            duration_ms=round(
                (time.monotonic() - started) * 1000
            ),
            checks=checks_tuple,
        )
