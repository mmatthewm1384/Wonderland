from __future__ import annotations

from wlbuilder.commands_util import run_command
from wlbuilder.context import BuilderContext
from wlbuilder.native_state import read_state, write_stage_state
from wlbuilder.stages.base import StageResult


class BootloaderStage:
    implemented = True
    name = "bootloader"
    description = "Install GRUB EFI bootloader into the mounted image."
    legacy_source = "build.__main__ bootloader stage"

    def run(self, context: BuilderContext) -> StageResult:
        rootfs = context.tmp_root / "mnt"
        state = read_state(context)
        mount_state = state.get("mount", {})

        if not rootfs.exists():
            return StageResult(self.name, False, f"rootfs mount missing: {rootfs}")

        loop = mount_state.get("loop")
        root_partition = mount_state.get("root_partition")

        if not loop or not root_partition:
            return StageResult(self.name, False, "missing loop/root partition state from mount stage")

        try:
            for path in ("dev", "proc", "sys", "run"):
                run_command(["sudo", "mount", "--bind", f"/{path}", str(rootfs / path)])

            run_command([
                "sudo",
                "chroot",
                str(rootfs),
                "grub-install",
                "--target=arm64-efi",
                "--efi-directory=/boot/efi",
                "--bootloader-id=WonderlandOS",
                "--recheck",
                "--no-nvram",
            ])

            run_command([
                "sudo",
                "chroot",
                str(rootfs),
                "update-grub",
            ])

        except Exception as exc:
            return StageResult(self.name, False, str(exc))

        write_stage_state(
            context,
            self.name,
            {
                "target": "arm64-efi",
                "bootloader_id": "WonderlandOS",
                "no_nvram": True,
                "loop": loop,
                "root_partition": root_partition,
            },
        )

        return StageResult(self.name, True, "installed GRUB EFI bootloader")
