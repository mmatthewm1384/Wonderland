from __future__ import annotations

import sys
from pathlib import Path
from pkgutil import extend_path


REPO_ROOT = Path(__file__).resolve().parent.parent
BUILDER_PYTHON = REPO_ROOT / "builder" / "python"

if BUILDER_PYTHON.exists():
    sys.path.insert(0, str(BUILDER_PYTHON))

__path__ = extend_path(__path__, __name__)
