from __future__ import annotations

import argparse
from collections.abc import Sequence

from wlbuilder.registry import COMMAND_SPECS


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="python3 -m wlbuilder",
        description="Wonderland OS Builder Runtime",
    )

    subcommands = parser.add_subparsers(dest="command")

    for spec in COMMAND_SPECS:
        command = subcommands.add_parser(spec.name, help=spec.help)

        if spec.name in {"stages", "native-state", "config", "migration"}:
            command.add_argument("--json", action="store_true", help="Emit output as JSON")

        if spec.name == "hygiene":
            command.add_argument("action", nargs="?", default="check", choices=("check", "restore"))

        if spec.name == "build":
            command.add_argument(
                "--profile",
                default="development",
                help="Builder profile to use",
            )

        command.set_defaults(command=spec.name)

    return parser


def parse(argv: Sequence[str] | None = None) -> argparse.Namespace:
    return build_parser().parse_args(list(argv) if argv is not None else None)
