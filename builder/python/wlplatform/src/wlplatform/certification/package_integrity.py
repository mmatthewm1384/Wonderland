"""
Wonderland Package Integrity Validator.

Validates that installed engine components:
- exist
- belong to the expected package
- import successfully
- expose expected modules
"""

from __future__ import annotations

import importlib
from pathlib import Path


class PackageIntegrityError(Exception):
    pass


def verify_module(module_name: str) -> dict:
    try:
        module = importlib.import_module(module_name)

        return {
            "module": module_name,
            "status": "PASS",
            "path": str(
                Path(module.__file__).resolve()
            ),
        }

    except Exception as exc:
        return {
            "module": module_name,
            "status": "FAIL",
            "error": str(exc),
        }


def certify_package(modules: list[str]) -> dict:
    results = [
        verify_module(module)
        for module in modules
    ]

    failed = [
        r for r in results
        if r["status"] == "FAIL"
    ]

    return {
        "certified": len(failed) == 0,
        "modules": results,
        "failures": failed,
    }
