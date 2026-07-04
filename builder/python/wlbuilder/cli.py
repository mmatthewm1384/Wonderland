from __future__ import annotations

import argparse
from collections.abc import Sequence

from wlbuilder.registry import COMMAND_SPECS, CommandArgument


def _add_argument(parser: argparse.ArgumentParser, argument: CommandArgument) -> None:
    if argument.kind == "flag":
        parser.add_argument(
            f"--{argument.name}",
            action="store_true",
            help=argument.help,
        )
        return

    if argument.kind == "optional":
        parser.add_argument(
            f"--{argument.name}",
            default=argument.default,
            choices=argument.choices or None,
            help=argument.help,
        )
        return

    if argument.kind == "positional":
        parser.add_argument(
            argument.name,
            nargs="?",
            default=argument.default,
            choices=argument.choices or None,
            help=argument.help,
        )
        return

    raise ValueError(f"Unsupported argument kind: {argument.kind}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="python3 -m wlbuilder",
        description="Wonderland OS Builder Runtime",
    )

    subcommands = parser.add_subparsers(dest="command")

    for spec in COMMAND_SPECS:
        command = subcommands.add_parser(spec.name, help=spec.help)

        for argument in spec.arguments:
            _add_argument(command, argument)

        command.set_defaults(command=spec.name)

    return parser


def parse(argv: Sequence[str] | None = None) -> argparse.Namespace:
    return build_parser().parse_args(list(argv) if argv is not None else None)
