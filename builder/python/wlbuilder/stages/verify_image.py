from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class VerifyImageStage:
    implemented = True
    name = "verify-image"
    description = "Verify boot-critical image contents."
    requires = ()
    produces = ()
    legacy_source = "native verify-image"

    def run(self, context: BuilderContext) -> StageResult:
        rootfs = context.tmp_root / "mnt"

        checks = [
            rootfs / "etc" / "os-release",
            rootfs / "etc" / "hostname",
            rootfs / "etc" / "fstab",
            rootfs / "boot" / "efi",
        ]

        missing = [str(path) for path in checks if not path.exists()]
        if missing:
            return StageResult(self.name, False, "missing: " + ", ".join(missing))

        return StageResult(self.name, True, "verified boot-critical image contents")
