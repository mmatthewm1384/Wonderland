from __future__ import annotations

import subprocess


class BootstrapStage:
    name = "bootstrap"

    def run(self, context) -> None:
        rootfs = context.output_root / "tmp" / "mnt"

        if not rootfs.exists():
            raise RuntimeError(f"Root filesystem mount does not exist: {rootfs}")

        if not (rootfs / "boot" / "efi").exists():
            raise RuntimeError(f"EFI mount path missing: {rootfs / 'boot' / 'efi'}")

        cmd = [
            "sudo",
            "debootstrap",
            "--arch=arm64",
            "bookworm",
            str(rootfs),
            "http://deb.debian.org/debian",
        ]

        subprocess.run(cmd, check=True)
