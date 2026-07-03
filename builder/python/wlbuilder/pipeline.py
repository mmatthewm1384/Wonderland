from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult
from wlbuilder.stages.disk import DiskStage
from wlbuilder.stages.mount import MountStage
from wlbuilder.stages.bootstrap import BootstrapStage
from wlbuilder.stages.packages import PackagesStage
from wlbuilder.stages.identity import IdentityStage
from wlbuilder.stages.locale import LocaleStage
from wlbuilder.stages.users import UsersStage
from wlbuilder.stages.networking import NetworkingStage
from wlbuilder.stages.bootloader import BootloaderStage
from wlbuilder.stages.verify_image import VerifyImageStage
from wlbuilder.stages.cleanup import CleanupStage
from wlbuilder.stages.convert import ConvertStage
from wlbuilder.stages.manifest import ManifestStage


STAGES = [
    DiskStage(),
    MountStage(),
    BootstrapStage(),
    PackagesStage(),
    IdentityStage(),
    LocaleStage(),
    UsersStage(),
    NetworkingStage(),
    BootloaderStage(),
    VerifyImageStage(),
    CleanupStage(),
    ConvertStage(),
    ManifestStage(),
]


def execute(context: BuilderContext) -> list[StageResult]:
    results: list[StageResult] = []

    try:
        for stage in STAGES:
            if not getattr(stage, "implemented", False):
                result = StageResult(
                    name=stage.name,
                    success=False,
                    message=f"stage is not implemented natively: {stage.name}",
                )
            else:
                result = stage.run(context)

            results.append(result)

            if not result.success:
                break

    finally:
        # Cleanup must always run after mount-capable stages.
        if not results or results[-1].name != "cleanup":
            cleanup = CleanupStage()
            cleanup_result = cleanup.run(context)
            results.append(cleanup_result)

    return results
