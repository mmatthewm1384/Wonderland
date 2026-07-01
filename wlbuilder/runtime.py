from __future__ import annotations

import platform
import sys


def run(argv: list[str] | None = None) -> int:
    """
    Primary wlbuilder runtime entry point.

    Normal builds must be launched through:

        bin/wl builder build --profile development

    Direct execution on macOS is intentionally blocked because the image
    builder requires the Linux builder VM environment.
    """
    if platform.system() == "Darwin":
        print("FAIL: direct wlbuilder execution on macOS is unsupported.", file=sys.stderr)
        print("Use:", file=sys.stderr)
        print("bin/wl builder build --profile development", file=sys.stderr)
        return 1

    from wlbuilder.cli import main

    return main(argv)
