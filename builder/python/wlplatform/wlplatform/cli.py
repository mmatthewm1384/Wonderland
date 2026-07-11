from __future__ import annotations

import argparse
import json
import sys

from . import __version__
from .certification import (
    CertificationError,
    certify,
)
from .context import PlatformContextError
from .controller import PlatformController
from .result import PlatformReport


def _render_report(
    report: PlatformReport,
    *,
    verbose: bool,
) -> None:
    print("Wonderland Platform Engine")
    print(f"version: {report.engine_version}")
    print()

    width = max(
        len(check.name)
        for check in report.checks
    )

    for check in report.checks:
        print(
            f"{check.name:<{width}}: "
            f"{check.status.value}"
        )

        if verbose:
            print(f"  summary: {check.summary}")
            print(f"  duration_ms: {check.duration_ms}")

            if check.command:
                print(
                    "  command: "
                    + " ".join(check.command)
                )

            if check.details:
                for key, value in sorted(
                    check.details.items()
                ):
                    print(f"  {key}: {value}")

            if check.stdout:
                print("  stdout:")

                for line in check.stdout.splitlines():
                    print(f"    {line}")

            if check.stderr:
                print("  stderr:")

                for line in check.stderr.splitlines():
                    print(f"    {line}")

    print()
    print(f"duration_ms: {report.duration_ms}")
    print()
    print(f"RESULT {report.result.value}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="wl platform",
        description="Wonderland Platform Engine",
    )
    parser.add_argument(
        "--version",
        action="version",
        version=__version__,
    )

    subparsers = parser.add_subparsers(
        dest="command",
    )

    for name in ("verify", "status", "doctor"):
        command = subparsers.add_parser(name)
        command.add_argument(
            "--json",
            action="store_true",
        )
        command.add_argument(
            "--verbose",
            action="store_true",
        )
        command.add_argument(
            "--include-optional",
            action="store_true",
            help="include Mirror and Academy checks",
        )

    certify_parser = subparsers.add_parser(
        "certify"
    )
    certify_parser.add_argument(
        "--json",
        action="store_true",
    )
    certify_parser.add_argument(
        "--include-optional",
        action="store_true",
    )

    subparsers.add_parser("help")

    return parser


def normalize_argv(
    argv: list[str],
) -> list[str]:
    if not argv:
        return ["verify"]

    if argv[0] in {
        "--json",
        "--verbose",
        "--include-optional",
    }:
        return ["verify", *argv]

    if argv[0] in {"-h", "--help"}:
        return ["help"]

    return argv


def main(argv: list[str] | None = None) -> int:
    argv = normalize_argv(
        list(sys.argv[1:] if argv is None else argv)
    )
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.command == "help":
        parser.print_help()
        return 0

    try:
        controller = PlatformController()
    except PlatformContextError as exc:
        print(f"FAIL {exc}", file=sys.stderr)
        return 1

    if args.command == "certify":
        try:
            output = certify(
                controller,
                include_optional=args.include_optional,
            )
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
                print("Wonderland Platform Certification")
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
            print("Wonderland Platform Certification")
            print()
            print(f"evidence: {output}")
            print()
            print("RESULT PASS")

        return 0

    report = controller.verify(
        include_optional=args.include_optional,
    )

    if args.json:
        print(
            json.dumps(
                report.to_dict(),
                indent=2,
                sort_keys=True,
            )
        )
    else:
        _render_report(
            report,
            verbose=args.verbose,
        )

    return report.exit_code


if __name__ == "__main__":
    raise SystemExit(main())
