from __future__ import annotations

import importlib
from pathlib import Path
import inspect
import platform
import sys
from collections.abc import Sequence
from typing import Any


def _reject_direct_macos_execution() -> int:
    print("FAIL: direct wlbuilder execution on macOS is unsupported.", file=sys.stderr)
    print("Use:", file=sys.stderr)
    print("bin/wl builder build --profile development", file=sys.stderr)
    return 1


def _call_main(main: Any, argv: Sequence[str] | None) -> int:
    signature = inspect.signature(main)
    parameters = signature.parameters

    if len(parameters) == 0:
        original_argv = sys.argv[:]
        try:
            if argv is not None:
                sys.argv = ["python3 -m wlbuilder", *list(argv)]
            result = main()
        finally:
            sys.argv = original_argv
    else:
        result = main(list(argv) if argv is not None else None)

    return int(result or 0)


def _run_existing_builder(argv: Sequence[str] | None = None) -> int:
    """
    Temporary Builder v2 bridge.

    Directly imports the existing builder runtime without using runpy or
    images/build-qcow2.py.
    """
    try:
        
        repo_root = Path(__file__).resolve().parents[3]
        if str(repo_root) not in sys.path:
            sys.path.insert(0, str(repo_root))

        module = importlib.import_module("build.__main__")
    except Exception as exc:
        print(f"FAIL: unable to import build.__main__: {exc}", file=sys.stderr)
        return 1

    main = getattr(module, "main", None)
    if main is None:
        print("FAIL: build.__main__ does not expose main().", file=sys.stderr)
        return 1

    try:
        return _call_main(main, argv)
    except Exception as exc:
        print(f"FAIL: builder runtime failed: {exc}", file=sys.stderr)
        return 1


def run(argv: Sequence[str] | None = None) -> int:
    if platform.system() == "Darwin":
        return _reject_direct_macos_execution()

    args = list(argv) if argv is not None else sys.argv[1:]

    # Backward compatibility:
    #   python3 -m wlbuilder --profile development
    #
    # Preferred Builder v2 form:
    #   python3 -m wlbuilder build --profile development
    if args and args[0].startswith("-"):
        args = ["build", *args]

    from wlbuilder.cli import build_parser, parse

    if args in (["-h"], ["--help"]):
        build_parser().print_help()
        return 0

    parsed = parse(args)

    if parsed.command == "status":
        repo_root = Path(__file__).resolve().parents[3]
        legacy_build = repo_root / "build" / "__main__.py"

        print("wlbuilder runtime: active")
        print(f"repo_root: {repo_root}")
        print(f"runtime: {Path(__file__).resolve()}")
        print("execution_path: builder/python/wlbuilder/runtime.py")
        print("legacy_bridge: build.__main__")
        print(f"legacy_bridge_file: {legacy_build}")
        print(f"legacy_bridge_exists: {str(legacy_build.exists()).lower()}")

        try:
            if str(repo_root) not in sys.path:
                sys.path.insert(0, str(repo_root))
            importlib.import_module("build.__main__")
            print("legacy_bridge_import: pass")
        except Exception as exc:
            print(f"legacy_bridge_import: fail: {exc}")

        return 0

    if parsed.command == "build":
        legacy_args = ["--profile", parsed.profile]
        return _run_existing_builder(legacy_args)

    print("FAIL: no builder command provided.", file=sys.stderr)
    return 1
