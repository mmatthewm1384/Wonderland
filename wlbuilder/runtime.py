from __future__ import annotations

import importlib
import platform
import sys
from collections.abc import Sequence


def _reject_direct_macos_execution() -> int:
    print("FAIL: direct wlbuilder execution on macOS is unsupported.", file=sys.stderr)
    print("Use:", file=sys.stderr)
    print("bin/wl builder build --profile development", file=sys.stderr)
    return 1


def _run_existing_builder(argv: Sequence[str] | None = None) -> int:
    """
    Temporary Builder v2 bridge.

    This preserves the existing working builder implementation while removing
    runpy and wrapper-script execution from the primary path.

    Target module:

        build.__main__

    Expected contract:

        main(argv: Sequence[str] | None = None) -> int
    """
    module = importlib.import_module("build.__main__")

    main = getattr(module, "main", None)
    if main is None:
        print("FAIL: build.__main__ does not expose main().", file=sys.stderr)
        return 1

    result = main(list(argv) if argv is not None else None)
    return int(result or 0)


def run(argv: Sequence[str] | None = None) -> int:
    """
    Sole wlbuilder runtime entry point.
    """
    if platform.system() == "Darwin":
        return _reject_direct_macos_execution()

    return _run_existing_builder(argv)
