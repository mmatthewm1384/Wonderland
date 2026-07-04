from __future__ import annotations

from wlbuilder.commands_util import run_command
from wlbuilder.context import BuilderContext
from wlbuilder.native_state import write_stage_state
from wlbuilder.stages.base import StageResult


class BootstrapStage:
    implemented = True
    name = "bootstrap"
    description = "Bootstrap Debian root filesystem."
    requires = ()
    produces = ()
    legacy_source = "build.__main__ bootstrap stage"

    def run(self, context: BuilderContext) -> StageResult:
        rootfs = context.tmp_root / "mnt"

        if not rootfs.exists():
            return StageResult(self.name, False, f"rootfs mount missing: {rootfs}")

        if not (rootfs / "boot" / "efi").exists():
            return StageResult(self.name, False, f"EFI mount path missing: {rootfs / 'boot' / 'efi'}")

        try:
            run_command([
                "sudo",
                "debootstrap",
                "--arch=arm64",
                "bookworm",
                str(rootfs),
                "http://deb.debian.org/debian",
            ])
        except Exception as exc:
            return StageResult(self.name, False, str(exc))

        write_stage_state(
            context,
            self.name,
            {
                "suite": "bookworm",
                "arch": "arm64",
                "rootfs": str(rootfs),
                "mirror": "http://deb.debian.org/debian",
            },
        )

        return StageResult(self.name, True, f"bootstrapped Debian bookworm at {rootfs}")
