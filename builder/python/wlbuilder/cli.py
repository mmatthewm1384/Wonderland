from __future__ import annotations

import argparse
from collections.abc import Sequence


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="python3 -m wlbuilder",
        description="Wonderland OS Builder Runtime",
    )

    subcommands = parser.add_subparsers(dest="command")

    status = subcommands.add_parser("status", help="Show builder runtime status")
    status.set_defaults(command="status")

    doctor = subcommands.add_parser("doctor", help="Run builder runtime diagnostics")
    doctor.set_defaults(command="doctor")


    build = subcommands.add_parser("build", help="Build a Wonderland OS image")
    build.add_argument(
        "--profile",
        default="development",
        help="Builder profile to use",
    )
    build.set_defaults(command="build")

    return parser


def parse(argv: Sequence[str] | None = None) -> argparse.Namespace:
    return build_parser().parse_args(list(argv) if argv is not None else None)
