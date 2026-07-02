from __future__ import annotations

import shutil
from pathlib import Path

from wlbuilder.context import BuilderContext


def collect_legacy_artifacts(context: BuilderContext) -> list[Path]:
    releases = context.repo_root / "releases"
    collected: list[Path] = []

    if not releases.is_dir():
        return collected

    for source in releases.glob("*.qcow2"):
        target = context.qcow2_output / source.name
        shutil.copy2(source, target)
        collected.append(target)

    for source in releases.glob("*.vmdk"):
        target = context.vmware_output / source.name
        shutil.copy2(source, target)
        collected.append(target)

    for source in releases.glob("*.manifest.json"):
        target = context.manifest_root / source.name
        shutil.copy2(source, target)
        collected.append(target)

    return collected
