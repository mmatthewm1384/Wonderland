from __future__ import annotations

import time
from collections.abc import Callable

from .version import __version__
from .context import PlatformContext
from .manifest_adapter import verify_manifests
from .registry_adapter import verify_registry
from .result import (
    CheckResult,
    PlatformReport,
    Status,
    aggregate_status,
)
from .subprocess_adapter import CommandSpec, run_command


Check = Callable[[PlatformContext], CheckResult]


class PlatformController:
    def __init__(
        self,
        context: PlatformContext | None = None,
    ) -> None:
        self.context = context or PlatformContext.discover()

    def _core_checks(self) -> tuple[Check, ...]:
        return (
            verify_registry,
            lambda context: run_command(
                context,
                CommandSpec(
                    name="architecture",
                    commands=(
                        ("bin/wl", "architecture", "verify"),
                        ("bin/wl", "architecture-verify"),
                        ("bin/wl-architecture-verify",),
                    ),
                ),
            ),
            lambda context: run_command(
                context,
                CommandSpec(
                    name="builder",
                    commands=(
                        ("bin/wl", "builder", "verify", "--json"),
                        ("bin/wl-builder", "verify", "--json"),
                        ("bin/wl", "builder", "doctor"),
                    ),
                    timeout=240,
                    idle_patterns=(
                        "builder vm: stopped",
                        "instance is stopped",
                    ),
                ),
            ),
            lambda context: run_command(
                context,
                CommandSpec(
                    name="governance",
                    commands=(
                        ("bin/wl", "governance", "verify", "--json"),
                        ("bin/wl-governance", "verify", "--json"),
                    ),
                    timeout=240,
                ),
            ),
            verify_manifests,
            lambda context: run_command(
                context,
                CommandSpec(
                    name="mirror",
                    commands=(
                        ("bin/wl", "mirror", "verify", "--json"),
                        ("bin/wl-mirror", "verify", "--json"),
                    ),
                    required=True,
                    timeout=300,
                    idle_patterns=(
                        '"result": "IDLE"',
                        "result idle",
                    ),
                ),
            ),
            lambda context: run_command(
                context,
                CommandSpec(
                    name="academy",
                    commands=(
                        ("bin/wl", "academy", "verify", "--json"),
                        ("bin/wl-academy", "verify", "--json"),
                    ),
                    required=True,
                    timeout=300,
                ),
            ),
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
