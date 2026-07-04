from __future__ import annotations

import subprocess
from pathlib import Path

from wlbuilder.context import BuilderContext
from wlbuilder.native_state import read_state, write_stage_state
from wlbuilder.stages.base import StageResult


class CleanupStage:
    implemented = True
    name = "cleanup"
    description = "Unmount image filesystems and detach loop devices."
    requires = ()
    produces = ()
    legacy_source = "native cleanup"

    def run(self, context: BuilderContext) -> StageResult:
        rootfs = context.tmp_root / "mnt"
        state = read_state(context)
        mount_state = state.get("mount", {})

        loop = mount_state.get("loop")
        errors: list[str] = []

        # Deepest mounts first. Repeat because previous failed builds may have stacked mounts.
        mountpoints = [
            rootfs / "run",
            rootfs / "sys",
            rootfs / "proc",
            rootfs / "dev",
            rootfs / "boot" / "efi",
            rootfs,
        ]

        for _ in range(8):
            for mountpoint in mountpoints:
                self._run(["sudo", "umount", str(mountpoint)], errors)

        # Lazy fallback for busy/stale mounts.
        for mountpoint in mountpoints:
            self._run(["sudo", "umount", "-l", str(mountpoint)], errors)

        if loop:
            self._run(["sudo", "losetup", "-d", loop], errors)

        # Last-resort detach stale loops from previous runs.
        self._run(["sudo", "losetup", "-D"], errors)

        try:
            rootfs.mkdir(parents=True, exist_ok=True)
        except Exception as exc:
            errors.append(f"failed to recreate mount root {rootfs}: {exc}")

        remaining = self._mounted_under(rootfs)

        write_stage_state(
            context,
            self.name,
            {
                "rootfs": str(rootfs),
                "loop": loop,
                "remaining_mounts": remaining,
                "errors": errors[-20:],
            },
        )

        if remaining:
            return StageResult(
                self.name,
                False,
                "cleanup incomplete: remaining mounts: " + ", ".join(remaining),
            )

        return StageResult(self.name, True, "unmounted filesystems and detached loop devices")

    @staticmethod
    def _run(command: list[str], errors: list[str]) -> None:
        result = subprocess.run(
            command,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if result.returncode not in (0, 32):  # 32 is common for "not mounted"
            stderr = result.stderr.strip()
            if stderr:
                errors.append(f"{' '.join(command)}: {stderr}")

    @staticmethod
    def _mounted_under(rootfs: Path) -> list[str]:
        result = subprocess.run(
            ["findmnt", "-R", str(rootfs), "-n", "-o", "TARGET"],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        if result.returncode != 0:
            return []

        return [line.strip() for line in result.stdout.splitlines() if line.strip()]
