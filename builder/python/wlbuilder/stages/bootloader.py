from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class BootloaderStage:
    name = "bootloader"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Install EFI bootloader and GRUB. Native implementation pending.",
        )
