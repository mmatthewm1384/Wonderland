from __future__ import annotations

import os
import platform
import sys
from collections.abc import Callable, Sequence
from pathlib import Path


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
    repo_root = _repo_root()
    commands = _commands()

    command = commands.get(parsed.command)
    if command is None:
        print(f"FAIL: unknown builder command: {parsed.command}", file=sys.stderr)
        return 1

    if parsed.command == "build":
        return command(repo_root, parsed.profile)

    if parsed.command == "hygiene":
        return command(getattr(parsed, "action", "check"))

    if parsed.command in {"stages", "native-state", "config", "migration"}:
        return command(repo_root, as_json=getattr(parsed, "json", False))

    return command(repo_root)
