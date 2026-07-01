from __future__ import annotations

import importlib
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

    return _run_existing_builder(argv)
