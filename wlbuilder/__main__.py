from __future__ import annotations

import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
BUILDER_PYTHON = REPO_ROOT / "builder" / "python"

if BUILDER_PYTHON.exists():
    sys.path.insert(0, str(BUILDER_PYTHON))

from wlbuilder.runtime import run


if __name__ == "__main__":
    raise SystemExit(run(sys.argv[1:]))
