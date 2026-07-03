from __future__ import annotations

from wlbuilder.artifacts import artifact_stem
from wlbuilder.commands_util import run_command
from wlbuilder.context import BuilderContext
from wlbuilder.native_state import write_stage_state
from wlbuilder.stages.base import StageResult


class DiskStage:
    implemented = True
    name = "disk"
    description = "Create raw disk image and partition layout."
    legacy_source = "build.__main__ stage 02 Disk"

    def run(self, context: BuilderContext) -> StageResult:
        raw_path = context.raw_output / f"{artifact_stem(context)}.raw"
        raw_path.parent.mkdir(parents=True, exist_ok=True)

        size = "8G"

        if raw_path.exists():
            raw_path.unlink()

        try:
            run_command(["qemu-img", "create", "-f", "raw", str(raw_path), size])
            run_command(["parted", "-s", str(raw_path), "mklabel", "gpt"])
            run_command([
                "parted",
                "-s",
                str(raw_path),
                "mkpart",
                "ESP",
                "fat32",
                "1MiB",
                "513MiB",
            ])
            run_command(["parted", "-s", str(raw_path), "set", "1", "esp", "on"])
            run_command([
                "parted",
                "-s",
                str(raw_path),
                "mkpart",
                "root",
                "ext4",
                "513MiB",
                "100%",
            ])
        except Exception as exc:
            return StageResult(self.name, False, str(exc))

        write_stage_state(
            context,
            self.name,
            {
                "raw_path": str(raw_path),
                "size": size,
            },
        )

        return StageResult(self.name, True, f"created {raw_path}")
