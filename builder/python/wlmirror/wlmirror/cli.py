from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

from .certification import (
    CertificationError,
    certify,
)
from .context import MirrorContext, MirrorContextError
from .verifier import main as verify_main
from .version import __version__


OPERATIONAL_COMMANDS = {
    "snapshot",
    "diff",
    "restore",
    "repair",
    "sync",
    "history",
    "clean",
}


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(
        prog="wl mirror",
        description="Wonderland Mirror Engine",
    )
    result.add_argument(
        "--version",
        action="version",
        version=__version__,
    )

    subparsers = result.add_subparsers(
        dest="command",
    )

    for name in ("verify", "status", "doctor"):
        command = subparsers.add_parser(name)
        command.add_argument("--json", action="store_true")
        command.add_argument(
            "--verbose",
            action="store_true",
        )

    certify_parser = subparsers.add_parser("certify")
    certify_parser.add_argument(
        "--json",
        action="store_true",
    )

    for name in sorted(OPERATIONAL_COMMANDS):
        command = subparsers.add_parser(name)
        command.add_argument(
            "args",
            nargs=argparse.REMAINDER,
        )

    subparsers.add_parser("help")

    return result


def normalize(argv: list[str]) -> list[str]:
    if not argv:
        return ["status"]

    if argv[0] in {"--json", "--verbose"}:
        return ["verify", *argv]

    if argv[0] in {"-h", "--help"}:
        return ["help"]

    return argv


def run_legacy(
    context: MirrorContext,
    command: str,
    args: list[str],
) -> int:
    candidates = (
        context.root / "bin/wl-mirror-legacy",
        context.root / "lib/mirror/cli.sh",
    )

    launcher = next(
        (
            candidate
            for candidate in candidates
            if candidate.is_file()
            and os.access(candidate, os.X_OK)
        ),
        None,
    )

    if launcher is None:
        print(
            f"FAIL Mirror operation unavailable: {command}",
            file=sys.stderr,
        )
        return 1

    completed = subprocess.run(
        [str(launcher), command, *args],
        cwd=context.root,
        env=context.environment(),
        check=False,
    )

    return completed.returncode


def doctor(context: MirrorContext) -> int:
    failures = 0

    print("Wonderland Mirror Doctor")
    print()

    checks = (
        (
            "Mirror authority launcher",
            context.root / "bin/wl-mirror",
            True,
        ),
        (
            "Mirror verifier",
            context.root / "bin/wl-mirror-verify",
            True,
        ),
        (
            "Mirror certification authority",
            context.root / "bin/wl-mirror-certify",
            True,
        ),
        (
            "Mirror Python package",
            context.root / "builder/python/wlmirror/wlmirror",
            False,
        ),
    )

    for label, path, executable in checks:
        valid = path.exists()

        if executable:
            valid = (
                valid
                and path.is_file()
                and os.access(path, os.X_OK)
            )

        if valid:
            print(f"PASS {label}")
        else:
            print(f"FAIL {label}")
            failures += 1

    legacy = context.root / "bin/wl-mirror-legacy"

    if legacy.is_file() and os.access(legacy, os.X_OK):
        print("PASS legacy Mirror operations")
    else:
        print("WARN legacy Mirror operations unavailable")

    print()

    if failures:
        print("RESULT FAIL")
        return 1

    print("RESULT PASS")
    return 0


def main(argv: list[str] | None = None) -> int:
    argv = normalize(
        list(sys.argv[1:] if argv is None else argv)
    )
    args = parser().parse_args(argv)

    if args.command == "help":
        parser().print_help()
        return 0

    try:
        context = MirrorContext.discover()
    except MirrorContextError as exc:
        print(f"FAIL {exc}", file=sys.stderr)
        return 1

    if args.command in {"verify", "status"}:
        verify_args: list[str] = []

        if args.json:
            verify_args.append("--json")

        if args.verbose:
            verify_args.append("--verbose")

        return verify_main(verify_args)

    if args.command == "doctor":
        return doctor(context)

    if args.command == "certify":
        try:
            output = certify(context)
        except CertificationError as exc:
            payload = {
                "schema_version": 1,
                "result": "FAIL",
                "error": str(exc),
            }

            if args.json:
                print(
                    json.dumps(
                        payload,
                        indent=2,
                        sort_keys=True,
                    )
                )
            else:
                print("Wonderland Mirror Certification")
                print()
                print(f"FAIL {exc}")
                print()
                print("RESULT FAIL")

            return 1

        payload = {
            "schema_version": 1,
            "result": "PASS",
            "certification": str(output),
        }

        if args.json:
            print(
                json.dumps(
                    payload,
                    indent=2,
                    sort_keys=True,
                )
            )
        else:
            print("Wonderland Mirror Certification")
            print()
            print(f"evidence: {output}")
            print()
            print("RESULT PASS")

        return 0

    if args.command in OPERATIONAL_COMMANDS:
        return run_legacy(
            context,
            args.command,
            args.args,
        )

    parser().print_help()
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
