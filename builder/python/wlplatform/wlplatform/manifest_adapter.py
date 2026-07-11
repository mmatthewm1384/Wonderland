from __future__ import annotations

import json
import time
from pathlib import Path

from .context import PlatformContext
from .result import CheckResult, Status


def verify_manifests(
    context: PlatformContext,
) -> CheckResult:
    started = time.monotonic()

    roots = [
        path
        for path in (
            context.root / "vault/05-Registry",
            context.root / "01-Platform/registry",
            context.root / "vault/08-Operations/releases",
        )
        if path.exists()
    ]

    if not roots:
        return CheckResult(
            name="manifest_index",
            status=Status.FAIL,
            summary="no manifest roots found",
        )

    files: set[Path] = set()

    for root in roots:
        files.update(
            path
            for path in root.rglob("*.json")
            if path.is_file()
            and "certifications" not in path.parts
            and "backups" not in path.parts
            and "quarantine" not in path.parts
        )

    failures: list[str] = []

    for path in sorted(files):
        try:
            content = path.read_text()

            if not content.strip():
                failures.append(
                    f"{path.relative_to(context.root)}: empty"
                )
                continue

            json.loads(content)
        except (
            OSError,
            UnicodeDecodeError,
            json.JSONDecodeError,
        ) as exc:
            failures.append(
                f"{path.relative_to(context.root)}: {exc}"
            )

    duration_ms = round(
        (time.monotonic() - started) * 1000
    )

    if failures:
        return CheckResult(
            name="manifest_index",
            status=Status.FAIL,
            summary=(
                f"{len(failures)} invalid manifest(s)"
            ),
            duration_ms=duration_ms,
            details={
                "failures": failures[:50],
                "manifest_count": len(files),
            },
        )

    return CheckResult(
        name="manifest_index",
        status=Status.PASS,
        summary=f"{len(files)} manifests validated",
        duration_ms=duration_ms,
        details={
            "manifest_count": len(files),
            "roots": [
                str(path.relative_to(context.root))
                for path in roots
            ],
        },
    )
