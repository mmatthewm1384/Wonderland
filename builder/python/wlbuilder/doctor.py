from __future__ import annotations

import importlib
import shutil
import sys
from dataclasses import dataclass
from pathlib import Path

from wlbuilder.context import create_context, ensure_output_dirs


@dataclass(frozen=True, slots=True)
class DoctorCheck:
    name: str
    passed: bool
    detail: str = ""


REQUIRED_TOOLS = (
    "python3",
    "qemu-img",
    "debootstrap",
    "parted",
    "mkfs.vfat",
    "mkfs.ext4",
    "grub-install",
)


def _check_tool(name: str) -> DoctorCheck:
    path = shutil.which(name)
    return DoctorCheck(
        name=f"tool:{name}",
        passed=path is not None,
        detail=path or "missing",
    )


def run_doctor(repo_root: Path | None = None) -> int:
    root = repo_root or Path.cwd()
    checks: list[DoctorCheck] = []

    checks.append(
        DoctorCheck(
            name="repo_root",
            passed=(root / "builder").is_dir(),
            detail=str(root),
        )
    )

    try:
        context = create_context(root)
        ensure_output_dirs(context)

        checks.append(
            DoctorCheck(
                name="config",
                passed=True,
                detail=str(context.config.path),
            )
        )

        for path in (
            context.output_root,
            context.raw_output,
            context.qcow2_output,
            context.vmware_output,
            context.log_root,
            context.manifest_root,
            context.cache_root,
            context.tmp_root,
        ):
            checks.append(
                DoctorCheck(
                    name=f"output:{path.relative_to(root)}",
                    passed=path.exists(),
                    detail=str(path),
                )
            )

    except Exception as exc:
        checks.append(
            DoctorCheck(
                name="config",
                passed=False,
                detail=str(exc),
            )
        )

    try:
        if str(root) not in sys.path:
            sys.path.insert(0, str(root))
        importlib.import_module("build.__main__")
        checks.append(DoctorCheck("legacy_bridge", True, "build.__main__"))
    except Exception as exc:
        checks.append(DoctorCheck("legacy_bridge", False, str(exc)))

    for tool in REQUIRED_TOOLS:
        checks.append(_check_tool(tool))

    failed = False

    print("Builder Doctor")
    print("--------------")

    for check in checks:
        status = "PASS" if check.passed else "FAIL"
        print(f"{status} {check.name}: {check.detail}")
        failed = failed or not check.passed

    return 1 if failed else 0
