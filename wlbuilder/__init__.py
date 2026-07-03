from __future__ import annotations

from pathlib import Path
from pkgutil import extend_path

__path__ = extend_path(__path__, __name__)

_repo_root = Path(__file__).resolve().parent.parent
_builder_pkg = _repo_root / "builder" / "python" / "wlbuilder"

if _builder_pkg.is_dir():
    __path__.append(str(_builder_pkg))
