from __future__ import annotations

import argparse
import hashlib
import json
import os
import stat
import subprocess
import sys
import time
from pathlib import Path
from typing import Callable

from .authority import (
    load_authority,
    resolve_destination,
    resolve_source,
)
from .context import MirrorContext, MirrorContextError
from .result import CheckResult, Status, aggregate
from .version import __version__


Check = Callable[[], CheckResult]


def _timed(name: str, callback: Check) -> CheckResult:
    started = time.monotonic()

    try:
        result = callback()
    except Exception as exc:
        result = CheckResult(
            name=name,
            status=Status.FAIL,
            summary=f"{type(exc).__name__}: {exc}",
        )

    return CheckResult(
        name=result.name,
        status=result.status,
        summary=result.summary,
        duration_ms=round(
            (time.monotonic() - started) * 1000
        ),
        details=result.details,
    )


def _is_executable(path: Path) -> bool:
    return (
        path.is_file()
        and bool(path.stat().st_mode & stat.S_IXUSR)
    )


def verify_launcher(
    context: MirrorContext,
) -> CheckResult:
    """
    Validate the thin authority launcher and the Python CLI contract.

    The shell launcher intentionally contains no command table; it delegates
    directly to `python3 -m wlmirror`. Command availability therefore must be
    validated from the actual CLI help output rather than from shell source.
    """
    launcher = context.root / "bin/wl-mirror"

    if not _is_executable(launcher):
        return CheckResult(
            "authority_launcher",
            Status.FAIL,
            "bin/wl-mirror is missing or not executable",
        )

    completed = subprocess.run(
        [str(launcher), "--help"],
        cwd=context.root,
        env=context.environment(),
        stdin=subprocess.DEVNULL,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=30,
        check=False,
    )

    if completed.returncode != 0:
        return CheckResult(
            "authority_launcher",
            Status.FAIL,
            f"Mirror authority help exited {completed.returncode}",
            details={
                "stdout": completed.stdout.strip(),
                "stderr": completed.stderr.strip(),
            },
        )

    output = (
        completed.stdout
        + "\n"
        + completed.stderr
    )

    required = {
        "doctor",
        "verify",
        "certify",
        "status",
        "snapshot",
        "diff",
        "restore",
    }

    missing = sorted(
        command
        for command in required
        if command not in output
    )

    if missing:
        return CheckResult(
            "authority_launcher",
            Status.FAIL,
            "Mirror authority CLI missing commands: "
            + ", ".join(missing),
            details={
                "path": "bin/wl-mirror",
            },
        )

    return CheckResult(
        "authority_launcher",
        Status.PASS,
        "Mirror authority launcher and Python CLI contract are complete",
        details={
            "path": "bin/wl-mirror",
            "commands": sorted(required),
        },
    )


def verify_public_route(
    context: MirrorContext,
) -> CheckResult:
    completed = subprocess.run(
        [str(context.root / "bin/wl"), "mirror", "--help"],
        cwd=context.root,
        env=context.environment(),
        stdin=subprocess.DEVNULL,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=30,
        check=False,
    )

    if completed.returncode != 0:
        return CheckResult(
            "public_route",
            Status.FAIL,
            f"wl mirror --help exited {completed.returncode}",
            details={
                "stderr": completed.stderr.strip(),
            },
        )

    required = (
        "doctor",
        "verify",
        "certify",
        "status",
        "snapshot",
        "diff",
        "restore",
    )
    output = (
        completed.stdout
        + "\n"
        + completed.stderr
    )
    missing = [
        command
        for command in required
        if command not in output
    ]

    if missing:
        return CheckResult(
            "public_route",
            Status.FAIL,
            "public Mirror route missing commands: "
            + ", ".join(missing),
        )

    return CheckResult(
        "public_route",
        Status.PASS,
        "wl mirror route is available",
    )


def verify_authority(
    context: MirrorContext,
) -> CheckResult:
    path, payload = load_authority(context)
    source = resolve_source(context, payload)
    destination = resolve_destination(
        context,
        payload,
    )

    if path is None:
        return CheckResult(
            "authority",
            Status.WARN,
            "no explicit Mirror authority file; using repository source",
            details={
                "source": str(source),
                "destination": (
                    str(destination)
                    if destination is not None
                    else None
                ),
            },
        )

    return CheckResult(
        "authority",
        Status.PASS,
        "Mirror authority configuration loaded",
        details={
            "authority_file": str(
                path.relative_to(context.root)
            ),
            "source": str(source),
            "destination": (
                str(destination)
                if destination is not None
                else None
            ),
        },
    )


def verify_source(
    context: MirrorContext,
) -> CheckResult:
    _, payload = load_authority(context)
    source = resolve_source(context, payload)

    if not source.exists():
        return CheckResult(
            "source",
            Status.FAIL,
            f"Mirror source does not exist: {source}",
        )

    if not source.is_dir():
        return CheckResult(
            "source",
            Status.FAIL,
            f"Mirror source is not a directory: {source}",
        )

    if not os.access(source, os.R_OK):
        return CheckResult(
            "source",
            Status.FAIL,
            f"Mirror source is not readable: {source}",
        )

    return CheckResult(
        "source",
        Status.PASS,
        "Mirror source is readable",
        details={"path": str(source)},
    )


def verify_destination(
    context: MirrorContext,
) -> CheckResult:
    _, payload = load_authority(context)
    destination = resolve_destination(
        context,
        payload,
    )

    if destination is None:
        return CheckResult(
            "destination",
            Status.IDLE,
            "Mirror destination is not configured",
        )

    if not destination.exists():
        return CheckResult(
            "destination",
            Status.IDLE,
            f"Mirror destination is currently unavailable: {destination}",
            details={"path": str(destination)},
        )

    if not destination.is_dir():
        return CheckResult(
            "destination",
            Status.FAIL,
            f"Mirror destination is not a directory: {destination}",
        )

    readable = os.access(destination, os.R_OK)
    writable = os.access(destination, os.W_OK)

    if not readable:
        return CheckResult(
            "destination",
            Status.FAIL,
            f"Mirror destination is not readable: {destination}",
        )

    return CheckResult(
        "destination",
        (
            Status.PASS
            if writable
            else Status.WARN
        ),
        (
            "Mirror destination is readable and writable"
            if writable
            else "Mirror destination is read-only"
        ),
        details={
            "path": str(destination),
            "writable": writable,
        },
    )


def verify_safety(
    context: MirrorContext,
) -> CheckResult:
    _, payload = load_authority(context)
    source = resolve_source(context, payload)
    destination = resolve_destination(
        context,
        payload,
    )

    if destination is None:
        return CheckResult(
            "path_safety",
            Status.PASS,
            "no destination configured; destructive checks inactive",
        )

    if source == destination:
        return CheckResult(
            "path_safety",
            Status.FAIL,
            "Mirror source and destination are identical",
        )

    if source in destination.parents:
        return CheckResult(
            "path_safety",
            Status.FAIL,
            "Mirror destination is nested inside source",
            details={
                "source": str(source),
                "destination": str(destination),
            },
        )

    if destination in source.parents:
        return CheckResult(
            "path_safety",
            Status.FAIL,
            "Mirror source is nested inside destination",
            details={
                "source": str(source),
                "destination": str(destination),
            },
        )

    return CheckResult(
        "path_safety",
        Status.PASS,
        "Mirror source and destination boundaries are safe",
    )


def verify_state(
    context: MirrorContext,
) -> CheckResult:
    candidates = (
        context.state_root / "mirror-status.json",
        context.state_root / "mirror-state.json",
        context.state_root / "mirror.json",
    )

    existing = [
        path
        for path in candidates
        if path.is_file()
    ]

    failures: list[str] = []

    for path in existing:
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

    if failures:
        return CheckResult(
            "persistent_state",
            Status.FAIL,
            "invalid Mirror persistent state",
            details={"failures": failures},
        )

    if not existing:
        return CheckResult(
            "persistent_state",
            Status.IDLE,
            "no Mirror persistent state has been created",
        )

    return CheckResult(
        "persistent_state",
        Status.PASS,
        f"{len(existing)} Mirror state artifact(s) parse",
        details={
            "files": [
                str(path.relative_to(context.root))
                for path in existing
            ],
        },
    )


def verify_legacy_launcher(
    context: MirrorContext,
) -> CheckResult:
    legacy = context.root / "bin/wl-mirror-legacy"

    if not legacy.exists():
        return CheckResult(
            "legacy_adapter",
            Status.SKIP,
            "no legacy Mirror operational launcher preserved",
        )

    if not _is_executable(legacy):
        return CheckResult(
            "legacy_adapter",
            Status.FAIL,
            "bin/wl-mirror-legacy is not executable",
        )

    return CheckResult(
        "legacy_adapter",
        Status.PASS,
        "legacy Mirror operations remain available",
        details={"path": "bin/wl-mirror-legacy"},
    )


def verify_nonrecursive(
    context: MirrorContext,
) -> CheckResult:
    launcher = context.root / "bin/wl-mirror"
    text = launcher.read_text(errors="replace")

    unsafe = (
        'exec "$ROOT/bin/wl" mirror',
        "exec bin/wl mirror",
        "wl mirror \"$@\"",
    )
    matches = [
        pattern
        for pattern in unsafe
        if pattern in text
    ]

    if matches:
        return CheckResult(
            "nonrecursive_contract",
            Status.FAIL,
            "Mirror launcher contains recursive public dispatch",
            details={"patterns": matches},
        )

    return CheckResult(
        "nonrecursive_contract",
        Status.PASS,
        "Mirror launcher is non-recursive",
    )


def verify(
    context: MirrorContext,
) -> tuple[
    tuple[CheckResult, ...],
    Status,
    int,
]:
    started = time.monotonic()

    checks: tuple[tuple[str, Check], ...] = (
        (
            "authority_launcher",
            lambda: verify_launcher(context),
        ),
        (
            "public_route",
            lambda: verify_public_route(context),
        ),
        (
            "authority",
            lambda: verify_authority(context),
        ),
        (
            "source",
            lambda: verify_source(context),
        ),
        (
            "destination",
            lambda: verify_destination(context),
        ),
        (
            "path_safety",
            lambda: verify_safety(context),
        ),
        (
            "persistent_state",
            lambda: verify_state(context),
        ),
        (
            "legacy_adapter",
            lambda: verify_legacy_launcher(context),
        ),
        (
            "nonrecursive_contract",
            lambda: verify_nonrecursive(context),
        ),
    )

    results = tuple(
        _timed(name, callback)
        for name, callback in checks
    )

    return (
        results,
        aggregate(results),
        round((time.monotonic() - started) * 1000),
    )


def render_text(
    results: tuple[CheckResult, ...],
    overall: Status,
    duration_ms: int,
    *,
    verbose: bool,
) -> None:
    print("Wonderland Mirror Verify")
    print(f"version: {__version__}")
    print()

    width = max(
        len(result.name)
        for result in results
    )

    for result in results:
        print(
            f"{result.name:<{width}}: "
            f"{result.status.value}"
        )

        if verbose:
            print(f"  {result.summary}")
            print(
                f"  duration_ms: "
                f"{result.duration_ms}"
            )

            for key, value in sorted(
                result.details.items()
            ):
                print(f"  {key}: {value}")

    print()
    print(f"duration_ms: {duration_ms}")
    print()
    print(f"RESULT {overall.value}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Verify Wonderland Mirror",
    )
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args(argv)

    try:
        context = MirrorContext.discover()
        results, overall, duration_ms = verify(context)
    except MirrorContextError as exc:
        if args.json:
            print(
                json.dumps(
                    {
                        "schema_version": 1,
                        "result": "FAIL",
                        "error": str(exc),
                    },
                    indent=2,
                    sort_keys=True,
                )
            )
        else:
            print(f"FAIL {exc}", file=sys.stderr)
            print("RESULT FAIL")

        return 1

    if args.json:
        print(
            json.dumps(
                {
                    "schema_version": 1,
                    "engine_version": __version__,
                    "root": str(context.root),
                    "result": overall.value,
                    "duration_ms": duration_ms,
                    "checks": [
                        result.to_dict()
                        for result in results
                    ],
                    "summary": {
                        status.value.lower(): sum(
                            result.status is status
                            for result in results
                        )
                        for status in Status
                    },
                },
                indent=2,
                sort_keys=True,
            )
        )
    else:
        render_text(
            results,
            overall,
            duration_ms,
            verbose=args.verbose,
        )

    return 1 if overall is Status.FAIL else 0


if __name__ == "__main__":
    raise SystemExit(main())
