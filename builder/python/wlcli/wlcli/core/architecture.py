from __future__ import annotations

from pathlib import Path

from wlcli.output import CommandResult, ResultLine


REQUIRED_PATHS = [
    "builder/python/wlcli/wlcli/core/__init__.py",
    "builder/python/wlcli/wlcli/core/architecture.py",
]


def verify_beta_architecture(root: Path) -> CommandResult:
    lines: list[ResultLine] = []
    failed = False

    for rel in REQUIRED_PATHS:
        path = root / rel
        if path.exists():
            lines.append(ResultLine("PASS", rel))
        else:
            failed = True
            lines.append(ResultLine("FAIL", rel, "missing"))

    return CommandResult(
        title="Runtime Engine 1.0 Beta Architecture",
        state="FAIL" if failed else "PASS",
        message="architecture incomplete" if failed else "beta core namespace available",
        lines=lines,
        metadata={
            "Internal namespace": "wlcli.core",
            "Compatibility": "top-level public imports preserved",
        },
    )
