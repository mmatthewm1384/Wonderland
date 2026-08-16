"""
Compatibility wrapper.

Canonical repository root resolution lives in:
    wlplatform.paths.repository_root

This module remains for backward compatibility only.
"""

from .paths import repository_root


def discover_root():
    return repository_root()
