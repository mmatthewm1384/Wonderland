from __future__ import annotations

from wlbuilder.commands_util import run_command
from wlbuilder.context import BuilderContext
from wlbuilder.native_state import write_stage_state
from wlbuilder.stages.base import StageResult


class PackagesStage:
    implemented = True
    name = "packages"
    description = "Install base Wonderland OS packages into the bootstrapped root filesystem."
    requires = ()
    produces = ()
    legacy_source = "build.__main__ packages stage"

    def run(self, context: BuilderContext) -> StageResult:
        rootfs = context.tmp_root / "mnt"

        if not rootfs.exists():
            return StageResult(self.name, False, f"rootfs mount missing: {rootfs}")

        if not (rootfs / "usr" / "bin" / "apt-get").exists():
            return StageResult(self.name, False, f"apt-get missing; rootfs is not bootstrapped: {rootfs}")

        packages = [
            "linux-image-arm64",
            "systemd-sysv",
            "sudo",
            "openssh-server",
            "ca-certificates",
            "curl",
            "vim",
            "git",
            "iproute2",
            "net-tools",
            "locales",
            "grub-efi-arm64",
            "efibootmgr",
        ]

        try:
            run_command(["sudo", "chroot", str(rootfs), "apt-get", "update"])
            run_command([
                "sudo",
                "chroot",
                str(rootfs),
                "/usr/bin/env",
                "DEBIAN_FRONTEND=noninteractive",
                "apt-get",
                "install",
                "-y",
                "--no-install-recommends",
                *packages,
            ])
        except Exception as exc:
            return StageResult(self.name, False, str(exc))

        write_stage_state(
            context,
            self.name,
            {
                "packages": packages,
                "package_count": len(packages),
                "rootfs": str(rootfs),
            },
        )

        return StageResult(self.name, True, f"installed {len(packages)} packages")
