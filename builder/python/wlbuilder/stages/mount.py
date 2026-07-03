from __future__ import annotations

import re
from pathlib import Path

from wlbuilder.commands_util import run_command
from wlbuilder.context import BuilderContext
from wlbuilder.native_state import read_state, write_stage_state
from wlbuilder.stages.base import StageResult


class MountStage:
    implemented = True
    name = "mount"
    description = "Attach image, create filesystems, and mount root/EFI filesystems."
    legacy_source = "build.__main__ stage 03 Mount"

    def _loop_device(self, output: str) -> str:
        match = re.search(r"(/dev/loop\d+)", output)
        if not match:
            raise RuntimeError(f"unable to detect loop device from losetup output: {output}")
        return match.group(1)

    def run(self, context: BuilderContext) -> StageResult:
        state = read_state(context)
        disk = state.get("disk", {})
        raw_path = Path(str(disk.get("raw_path", "")))

        if not raw_path.exists():
            return StageResult(self.name, False, f"raw image missing: {raw_path}")

        mount_root = context.tmp_root / "mnt"
        efi_mount = mount_root / "boot" / "efi"

        try:
            run_command(["sudo", "mkdir", "-p", str(mount_root)])

            result = run_command(["sudo", "losetup", "--find", "--partscan", "--show", str(raw_path)])
            loop = self._loop_device(result.stdout.strip())

            efi_partition = f"{loop}p1"
            root_partition = f"{loop}p2"

            run_command(["sudo", "mkfs.vfat", "-F", "32", efi_partition])
            run_command(["sudo", "mkfs.ext4", "-F", root_partition])

            run_command(["sudo", "mount", root_partition, str(mount_root)])
            run_command(["sudo", "mkdir", "-p", str(efi_mount)])
            run_command(["sudo", "mount", efi_partition, str(efi_mount)])

        except Exception as exc:
            return StageResult(self.name, False, str(exc))

        write_stage_state(
            context,
            self.name,
            {
                "loop": loop,
                "efi_partition": efi_partition,
                "root_partition": root_partition,
                "mount_root": str(mount_root),
                "efi_mount": str(efi_mount),
            },
        )

        return StageResult(self.name, True, f"mounted {raw_path} at {mount_root}")
