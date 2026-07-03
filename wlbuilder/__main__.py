from __future__ import annotations

import sys
from pathlib import Path

_repo_root = Path(__file__).resolve().parent.parent
_builder_python = _repo_root / "builder" / "python"

if str(_builder_python) not in sys.path:
    sys.path.insert(0, str(_builder_python))

from wlbuilder.runtime import run

raise SystemExit(run(sys.argv[1:]))
