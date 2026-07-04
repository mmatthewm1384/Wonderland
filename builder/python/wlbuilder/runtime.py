from __future__ import annotations

import inspect
import os
import platform
import sys
from collections.abc import Callable, Sequence
from pathlib import Path
from typing import Any


Command = Callable[..., int]


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _reject_direct_macos_execution() -> int:
    print("FAIL: direct wlbuilder execution on macOS is unsupported.", file=sys.stderr)
    print("Use:", file=sys.stderr)
    print("  bin/wl builder build --profile development", file=sys.stderr)
    return 1


def _commands() -> dict[str, Command]:
    from wlbuilder.commands.artifacts import run as artifacts
    from wlbuilder.commands.build import run as build
    from wlbuilder.commands.config import run as config
    from wlbuilder.commands.docs import run as docs
    from wlbuilder.commands.doctor import run as doctor
    from wlbuilder.commands.hygiene import run as hygiene
    from wlbuilder.commands.migration import run as migration
    from wlbuilder.commands.native_state import run as native_state
    from wlbuilder.commands.stages import run as stages
    from wlbuilder.commands.status import run as status
    from wlbuilder.commands.verify import run as verify

    commands: dict[str, Command] = {
        "artifacts": artifacts,
        "build": build,
        "config": config,
        "docs": docs,
        "doctor": doctor,
        "hygiene": hygiene,
        "migration": migration,
        "native-state": native_state,
        "stages": stages,
        "status": status,
        "verify": verify,
    }

    try:
        from wlbuilder.commands.contract import run as contract

        commands["contract"] = contract
    except ImportError:
        pass

    return commands


def _dispatch(command: Command, repo_root: Path, parsed: Any) -> int:
    parsed_args = vars(parsed).copy()
    parsed_args.pop("command", None)

    if "json" in parsed_args:
        parsed_args["as_json"] = parsed_args.pop("json")

    signature = inspect.signature(command)
    parameters = signature.parameters

    kwargs: dict[str, Any] = {}

    if "repo_root" in parameters:
        kwargs["repo_root"] = repo_root

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
    commands = _commands()

    command = commands.get(parsed.command)
    if command is None:
        print(f"FAIL: unknown builder command: {parsed.command}", file=sys.stderr)
        return 1

    return _dispatch(command, _repo_root(), parsed)
