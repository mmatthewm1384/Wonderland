"""
DEPRECATED COMPATIBILITY WRAPPER

This module is retained for backward compatibility only.

Active dependency verification path:

    bin/wl
        ->
    wlplatform.cli
        ->
    RegistryService

Do not add new callers to this module.
"""

import warnings
from pathlib import Path
import sys

from ..paths import repository_root


warnings.warn(
    "wlplatform.registry.check_dependencies is deprecated. "
    "Use: bin/wl registry verify-dependencies PACKAGE",
    DeprecationWarning,
    stacklevel=2,
)


ROOT = repository_root()

sys.path.insert(
    0,
    str(
        ROOT /
        "builder/python/wlplatform/src"
    )
)


from wlplatform.registry.registry_cli import main


if __name__ == "__main__":
    main()
