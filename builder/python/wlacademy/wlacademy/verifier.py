from __future__ import annotations

import argparse
import ast
import json
import os
import stat
import subprocess
import sys
import time
from pathlib import Path
from typing import Callable

from .context import AcademyContext, AcademyContextError
from .discovery import (
    CHAPTER_REGISTRY_CANDIDATES,
    LESSON_REGISTRY_CANDIDATES,
    collection_count,
    discover_lesson_files,
    first_existing,
    load_json,
)
from .result import CheckResult, Status, aggregate
from .version import __version__


Check = Callable[[], CheckResult]


def _timed(
    name: str,
    callback: Check,
) -> CheckResult:
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
    context: AcademyContext,
) -> CheckResult:
    launcher = context.root / "bin/wl-academy"

    if not _is_executable(launcher):
        return CheckResult(
            "authority_launcher",
            Status.FAIL,
            "bin/wl-academy is missing or not executable",
        )

    completed = subprocess.run(
        [str(launcher), "--help"],
        cwd=context.root,
        env=context.environment(),
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        timeout=30,
        check=False,
    )

    if completed.returncode != 0:
        return CheckResult(
            "authority_launcher",
            Status.FAIL,
            f"Academy authority help exited {completed.returncode}",
            details={
                "stdout": completed.stdout.strip(),
                "stderr": completed.stderr.strip(),
            },
        )

    output = completed.stdout + "\n" + completed.stderr

    required = {
        "doctor",
        "verify",
        "certify",
        "status",
        "lesson",
        "chapter",
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
            "Academy authority CLI missing commands: "
            + ", ".join(missing),
        )

    return CheckResult(
        "authority_launcher",
        Status.PASS,
        "Academy authority launcher and CLI contract are complete",
        details={
            "path": "bin/wl-academy",
            "commands": sorted(required),
        },
    )


def verify_public_route(
    context: AcademyContext,
) -> CheckResult:
    completed = subprocess.run(
        [str(context.root / "bin/wl"), "academy", "--help"],
        cwd=context.root,
        env=context.environment(),
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        timeout=30,
        check=False,
    )

    if completed.returncode != 0:
        return CheckResult(
            "public_route",
            Status.FAIL,
            f"wl academy --help exited {completed.returncode}",
            details={
                "stderr": completed.stderr.strip(),
            },
        )

    output = completed.stdout + "\n" + completed.stderr

    required = (
        "doctor",
        "verify",
        "certify",
        "status",
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
            "public Academy route missing commands: "
            + ", ".join(missing),
        )

    return CheckResult(
        "public_route",
        Status.PASS,
        "wl academy route is available",
    )


def verify_academy_root(
    context: AcademyContext,
) -> CheckResult:
    root = context.academy_root

    if not root.is_dir():
        return CheckResult(
            "academy_root",
            Status.FAIL,
            "academy root is missing",
            details={"path": str(root)},
        )

    files = [
        path
        for path in root.rglob("*")
        if path.is_file()
        and "__pycache__" not in path.parts
    ]

    if not files:
        return CheckResult(
            "academy_root",
            Status.FAIL,
            "academy root contains no files",
        )

    return CheckResult(
        "academy_root",
        Status.PASS,
        f"Academy root contains {len(files)} files",
        details={
            "path": str(root.relative_to(context.root)),
            "file_count": len(files),
        },
    )


def verify_chapter_registry(
    context: AcademyContext,
) -> CheckResult:
    path = first_existing(
        context,
        CHAPTER_REGISTRY_CANDIDATES,
    )

    if path is None:
        return CheckResult(
            "chapter_registry",
            Status.WARN,
            "no explicit chapter registry found",
        )

    payload = load_json(path)
    count = collection_count(payload)

    if count <= 0:
        return CheckResult(
            "chapter_registry",
            Status.FAIL,
            "chapter registry is empty",
            details={
                "path": str(path.relative_to(context.root)),
            },
        )

    return CheckResult(
        "chapter_registry",
        Status.PASS,
        f"{count} chapter entries registered",
        details={
            "path": str(path.relative_to(context.root)),
            "chapter_count": count,
        },
    )


def verify_lesson_registry(
    context: AcademyContext,
) -> CheckResult:
    path = first_existing(
        context,
        LESSON_REGISTRY_CANDIDATES,
    )
    lesson_files = discover_lesson_files(context)

    if path is None:
        if not lesson_files:
            return CheckResult(
                "lesson_registry",
                Status.FAIL,
                "no lesson registry or lesson Markdown found",
            )

        return CheckResult(
            "lesson_registry",
            Status.WARN,
            (
                f"no explicit lesson registry; "
                f"{len(lesson_files)} lessons discovered"
            ),
            details={
                "mode": "filesystem",
                "lesson_count": len(lesson_files),
            },
        )

    payload = load_json(path)
    count = collection_count(payload)

    if count <= 0:
        return CheckResult(
            "lesson_registry",
            Status.FAIL,
            "lesson registry is empty",
            details={
                "path": str(path.relative_to(context.root)),
            },
        )

    return CheckResult(
        "lesson_registry",
        Status.PASS,
        f"{count} lesson entries registered",
        details={
            "path": str(path.relative_to(context.root)),
            "lesson_count": count,
            "mode": "registry",
        },
    )


def verify_json_integrity(
    context: AcademyContext,
) -> CheckResult:
    roots = [
        path
        for path in (
            context.academy_root,
            context.root / "vault/05-Registry/academy",
        )
        if path.exists()
    ]

    files: set[Path] = set()

    for root in roots:
        if root.is_file():
            files.add(root)
        else:
            files.update(
                path
                for path in root.rglob("*.json")
                if path.is_file()
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

    if failures:
        return CheckResult(
            "json_integrity",
            Status.FAIL,
            "invalid Academy JSON",
            details={"failures": failures[:50]},
        )

    return CheckResult(
        "json_integrity",
        Status.PASS,
        f"{len(files)} Academy JSON files parse",
        details={"json_count": len(files)},
    )


def verify_markdown(
    context: AcademyContext,
) -> CheckResult:
    files = sorted(
        path
        for path in context.academy_root.rglob("*.md")
        if path.is_file()
        and path.name.lower() != "readme.md"
        and "registry" not in path.parts
        and "__pycache__" not in path.parts
    )

    if not files:
        return CheckResult(
            "markdown",
            Status.FAIL,
            "Academy contains no lesson Markdown documents",
        )

    exemption_path = (
        context.academy_root
        / "registry/heading-exemptions.json"
    )
    exemptions: set[str] = set()

    if exemption_path.is_file():
        payload = json.loads(exemption_path.read_text())
        entries = payload.get("exemptions", [])

        if not isinstance(entries, list):
            return CheckResult(
                "markdown",
                Status.FAIL,
                "heading exemption registry is malformed",
            )

        for entry in entries:
            if not isinstance(entry, dict):
                continue

            value = entry.get("path")

            if isinstance(value, str) and value.strip():
                exemptions.add(value.strip())

    empty: list[str] = []
    unexempted_headingless: list[str] = []
    stale_exemptions = set(exemptions)

    for document in files:
        relative = str(document.relative_to(context.root))
        content = document.read_text(errors="replace")

        if not content.strip():
            empty.append(relative)
            continue

        has_heading = any(
            line.lstrip().startswith("#")
            for line in content.splitlines()
        )

        if has_heading:
            stale_exemptions.discard(relative)
            continue

        if relative in exemptions:
            stale_exemptions.discard(relative)
        else:
            unexempted_headingless.append(relative)

    if empty:
        return CheckResult(
            "markdown",
            Status.FAIL,
            "empty Academy Markdown files detected",
            details={"files": empty[:100]},
        )

    if unexempted_headingless:
        return CheckResult(
            "markdown",
            Status.FAIL,
            "unapproved headingless Academy Markdown detected",
            details={
                "files": unexempted_headingless[:100],
            },
        )

    if stale_exemptions:
        return CheckResult(
            "markdown",
            Status.WARN,
            "stale Academy heading exemptions detected",
            details={
                "files": sorted(stale_exemptions)[:100],
            },
        )

    return CheckResult(
        "markdown",
        Status.PASS,
        (
            f"{len(files)} Academy Markdown files validated; "
            f"{len(exemptions)} explicit heading exemptions"
        ),
        details={
            "markdown_count": len(files),
            "heading_exemption_count": len(exemptions),
            "exemption_registry": str(
                exemption_path.relative_to(context.root)
            ),
        },
    )


def verify_python(
    context: AcademyContext,
) -> CheckResult:
    roots = [
        path
        for path in (
            context.root / "builder/python/wlacademy",
            context.root / "academy",
        )
        if path.exists()
    ]

    files: set[Path] = set()

    for root in roots:
        files.update(
            path
            for path in root.rglob("*.py")
            if path.is_file()
            and "__pycache__" not in path.parts
        )

    failures: list[str] = []

    for path in sorted(files):
        try:
            ast.parse(
                path.read_text(),
                filename=str(path),
            )
        except (
            SyntaxError,
            UnicodeDecodeError,
        ) as exc:
            failures.append(
                f"{path.relative_to(context.root)}: {exc}"
            )

    if failures:
        return CheckResult(
            "python_integrity",
            Status.FAIL,
            "Academy Python AST failures",
            details={"failures": failures[:50]},
        )

    return CheckResult(
        "python_integrity",
        Status.PASS,
        f"{len(files)} Academy Python modules parse",
        details={"module_count": len(files)},
    )


def verify_manifest_consistency(
    context: AcademyContext,
) -> CheckResult:
    registry_path = first_existing(
        context,
        LESSON_REGISTRY_CANDIDATES,
    )

    if registry_path is None:
        return CheckResult(
            "manifest_consistency",
            Status.FAIL,
            "canonical lesson registry is missing",
        )

    payload = load_json(registry_path)
    registry_count = collection_count(payload)
    lesson_files = discover_lesson_files(context)
    file_count = len(lesson_files)

    if registry_count != file_count:
        return CheckResult(
            "manifest_consistency",
            Status.FAIL,
            (
                "lesson registry/file count mismatch: "
                f"registry={registry_count}, files={file_count}"
            ),
            details={
                "registry_count": registry_count,
                "file_count": file_count,
                "registry_path": str(
                    registry_path.relative_to(context.root)
                ),
            },
        )

    registered_paths: set[str] = set()

    if isinstance(payload, dict):
        entries = payload.get("lessons", [])

        if isinstance(entries, list):
            for entry in entries:
                if not isinstance(entry, dict):
                    continue

                value = entry.get("path")

                if isinstance(value, str):
                    registered_paths.add(value)

    discovered_paths = {
        str(path.relative_to(context.root))
        for path in lesson_files
    }

    missing_paths = sorted(
        discovered_paths - registered_paths
    )
    stale_paths = sorted(
        registered_paths - discovered_paths
    )

    if missing_paths or stale_paths:
        return CheckResult(
            "manifest_consistency",
            Status.FAIL,
            "lesson registry paths do not match filesystem",
            details={
                "missing_paths": missing_paths[:100],
                "stale_paths": stale_paths[:100],
            },
        )

    return CheckResult(
        "manifest_consistency",
        Status.PASS,
        f"lesson registry matches {file_count} lesson files",
        details={
            "registry_count": registry_count,
            "file_count": file_count,
        },
    )


def verify_legacy_adapter(
    context: AcademyContext,
) -> CheckResult:
    legacy = context.root / "bin/wl-academy-legacy"

    if not legacy.exists():
        return CheckResult(
            "legacy_adapter",
            Status.SKIP,
            "no legacy Academy launcher preserved",
        )

    if not _is_executable(legacy):
        return CheckResult(
            "legacy_adapter",
            Status.FAIL,
            "bin/wl-academy-legacy is not executable",
        )

    return CheckResult(
        "legacy_adapter",
        Status.PASS,
        "legacy Academy operations remain available",
        details={"path": "bin/wl-academy-legacy"},
    )


def verify_nonrecursive(
    context: AcademyContext,
) -> CheckResult:
    launcher = context.root / "bin/wl-academy"
    text = launcher.read_text(errors="replace")

    unsafe = (
        'exec "$ROOT/bin/wl" academy',
        "exec bin/wl academy",
        "wl academy \"$@\"",
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
            "Academy launcher contains recursive public dispatch",
            details={"patterns": matches},
        )

    return CheckResult(
        "nonrecursive_contract",
        Status.PASS,
        "Academy launcher is non-recursive",
    )


def verify(
    context: AcademyContext,
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
            "academy_root",
            lambda: verify_academy_root(context),
        ),
        (
            "chapter_registry",
            lambda: verify_chapter_registry(context),
        ),
        (
            "lesson_registry",
            lambda: verify_lesson_registry(context),
        ),
        (
            "json_integrity",
            lambda: verify_json_integrity(context),
        ),
        (
            "markdown",
            lambda: verify_markdown(context),
        ),
        (
            "python_integrity",
            lambda: verify_python(context),
        ),
        (
            "manifest_consistency",
            lambda: verify_manifest_consistency(context),
        ),
        (
            "legacy_adapter",
            lambda: verify_legacy_adapter(context),
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
    print("Wonderland Academy Verify")
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
        description="Verify Wonderland Academy",
    )
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args(argv)

    try:
        context = AcademyContext.discover()
        results, overall, duration_ms = verify(context)
    except AcademyContextError as exc:
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
