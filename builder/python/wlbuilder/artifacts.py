from __future__ import annotations

import shutil
from pathlib import Path

from wlbuilder.context import BuilderContext


def _artifact_version(context: BuilderContext) -> str:
    data = context.config.data
    return str(data.get("system", {}).get("version") or data.get("version") or "0.1.1")


def _artifact_arch(context: BuilderContext) -> str:
    data = context.config.data
    return str(data.get("system", {}).get("architecture", "arm64"))


def artifact_stem(context: BuilderContext) -> str:
    return f"wonderland-os-{_artifact_version(context)}-{_artifact_arch(context)}-{context.profile}"


def collect_legacy_artifacts(context: BuilderContext) -> list[Path]:
    releases = context.repo_root / "releases"
    collected: list[Path] = []

    if not releases.is_dir():
        return collected

    stem = artifact_stem(context)

    mappings = [
        ("*.qcow2", context.qcow2_output, f"{stem}.qcow2"),
        ("*.vmdk", context.vmware_output, f"{stem}.vmdk"),
        ("*.manifest.json", context.manifest_root, f"{stem}.manifest.json"),
    ]

    for pattern, output_dir, filename in mappings:
        matches = sorted(releases.glob(pattern), key=lambda path: path.stat().st_mtime, reverse=True)

        if not matches:
            continue

        source = matches[0]
        target = output_dir / filename
        shutil.copy2(source, target)
        collected.append(target)

    return collected
