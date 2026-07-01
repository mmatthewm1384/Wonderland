#!/usr/bin/env python3
from __future__ import annotations

import sys
import warnings
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
BUILDER_PYTHON = REPO_ROOT / "builder" / "python"

if BUILDER_PYTHON.exists():
    sys.path.insert(0, str(BUILDER_PYTHON))
else:
    sys.path.insert(0, str(REPO_ROOT))


warnings.warn(
    "images/build-qcow2.py is deprecated. Use: bin/wl builder build --profile development",
    DeprecationWarning,
    stacklevel=2,
)

from wlbuilder.runtime import run


if __name__ == "__main__":
    raise SystemExit(run(sys.argv[1:]))
