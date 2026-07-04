from __future__ import annotations

import inspect
import os
import platform
import sys
from collections.abc import Callable, Sequence
from pathlib import Path
from typing import Any

from wlbuilder.registry import load_commands


Command = Callable[..., int]


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _reject_direct_macos_execution() -> int:
    print("FAIL: direct wlbuilder execution on macOS is unsupported.", file=sys.stderr)
    print("Use:", file=sys.stderr)
    print("  bin/wl builder build --profile development", file=sys.stderr)
    return 1


def _dispatch(command: Command, repo_root: Path, parsed: Any) -> int:
    parsed_args = vars(parsed).copy()
    parsed_args.pop("command", None)

    if "json" in parsed_args:
        parsed_args["as_json"] = parsed_args.pop("json")

    signature = inspect.signature(command)
    parameters = signature.parameters

    kwargs: dict[str, Any] = {"repo_root": repo_root}

    accepts_var_kwargs = any(
        parameter.kind == inspect.Parameter.VAR_KEYWORD
        for parameter in parameters.values()
    )

    for key, value in parsed_args.items():
        if accepts_var_kwargs or key in parameters:
            kwargs[key] = value

    return command(**kwargs)


def run(argv: Sequence[str] | None = None) -> int:
    if platform.system() == "Darwin" and os.environ.get("WL_BUILDER_MANAGED") != "1":
        return _reject_direct_macos_execution()

    args = list(argv) if argv is not None else sys.argv[1:]

    from wlbuilder.cli import build_parser, parse

    if args in (["-h"], ["--help"]):
        build_parser().print_help()
        return 0

    if not args:
        args = ["build"]

    if args[0].startswith("-"):
        args = ["build", *args]

    parsed = parse(args)
    commands = load_commands()

    command = commands.get(parsed.command)
    if command is None:
        print(f"FAIL: unknown builder command: {parsed.command}", file=sys.stderr)
        return 1

    return _dispatch(command, _repo_root(), parsed)
