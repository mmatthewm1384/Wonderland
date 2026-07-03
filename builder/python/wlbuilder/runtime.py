from __future__ import annotations

import platform
import sys
from collections.abc import Sequence
from pathlib import Path


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _reject_direct_macos_execution() -> int:
    print("FAIL: direct wlbuilder execution on macOS is unsupported.", file=sys.stderr)
    print("Use:", file=sys.stderr)
    print("  bin/wl builder build --profile development", file=sys.stderr)
    return 1


def run(argv: Sequence[str] | None = None) -> int:
    if platform.system() == "Darwin":
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

    if parsed.command == "status":
        from wlbuilder.commands.status import run as command

        return command(_repo_root())

    if parsed.command == "doctor":
        from wlbuilder.commands.doctor import run as command

        return command(_repo_root())

    if parsed.command == "verify":
        from wlbuilder.commands.verify import run as command

        return command(_repo_root())

    if parsed.command == "docs":
        from wlbuilder.commands.docs import run as command

        return command(_repo_root())

    if parsed.command == "artifacts":
        from wlbuilder.commands.artifacts import run as command

        return command(_repo_root())

    if parsed.command == "stages":
        from wlbuilder.commands.stages import run as command

        return command(as_json=getattr(parsed, "json", False))

    if parsed.command == "native-state":
        from wlbuilder.commands.native_state import run as command

        return command(_repo_root(), as_json=getattr(parsed, "json", False))

    if parsed.command == "config":
        from wlbuilder.commands.config import run as command

        return command(_repo_root(), as_json=getattr(parsed, "json", False))

    if parsed.command == "build":
        from wlbuilder.commands.build import run as command

        return command(_repo_root(), parsed.profile)

    print("FAIL: no builder command provided.", file=sys.stderr)
    return 1
