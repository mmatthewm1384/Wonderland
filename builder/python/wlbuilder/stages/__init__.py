from __future__ import annotations

from wlbuilder.stage_types import BuilderStage
from wlbuilder.stages.artifacts import ArtifactStage
from wlbuilder.stages.bootloader import BootloaderStage
from wlbuilder.stages.bootstrap import BootstrapStage
from wlbuilder.stages.cleanup import CleanupStage
from wlbuilder.stages.filesystem import FilesystemStage
from wlbuilder.stages.manifest import ManifestStage
from wlbuilder.stages.packages import PackageStage


def default_pipeline() -> list[BuilderStage]:
    return [
        BootstrapStage(),
        FilesystemStage(),
        PackageStage(),
        BootloaderStage(),
        ManifestStage(),
        ArtifactStage(),
        CleanupStage(),
    ]


__all__ = [
    "ArtifactStage",
    "BootloaderStage",
    "BootstrapStage",
    "CleanupStage",
    "FilesystemStage",
    "ManifestStage",
    "PackageStage",
    "default_pipeline",
]
