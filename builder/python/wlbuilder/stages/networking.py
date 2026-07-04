from __future__ import annotations

import shlex

from wlbuilder.commands_util import run_command
from wlbuilder.context import BuilderContext
from wlbuilder.native_state import write_stage_state
from wlbuilder.stages.base import StageResult


class NetworkingStage:
    implemented = True
    name = "networking"
    description = "Configure basic DHCP networking and SSH."
    requires = ()
    produces = ()
    legacy_source = "build.__main__ networking stage"

    def run(self, context: BuilderContext) -> StageResult:
        rootfs = context.tmp_root / "mnt"

        if not rootfs.exists():
            return StageResult(self.name, False, f"rootfs mount missing: {rootfs}")

        network_dir = rootfs / "etc" / "systemd" / "network"

        network_config = """[Match]
Name=en*

[Network]
DHCP=yes
"""

        resolv_conf = """nameserver 1.1.1.1
nameserver 8.8.8.8
"""

        try:
            run_command(["sudo", "mkdir", "-p", str(network_dir)])

            run_command([
                "bash",
                "-lc",
                f"cat > /tmp/wonderland-network <<'EOF'\n{network_config}EOF\n"
                f"sudo cp /tmp/wonderland-network {shlex.quote(str(network_dir / '20-wired.network'))}\n"
                "rm -f /tmp/wonderland-network",
            ])

            run_command([
                "sudo",
                "chroot",
                str(rootfs),
                "systemctl",
                "enable",
                "systemd-networkd.service",
            ])

            run_command([
                "sudo",
                "chroot",
                str(rootfs),
                "systemctl",
                "enable",
                "ssh.service",
            ])

            run_command([
                "bash",
                "-lc",
                f"cat > /tmp/wonderland-resolv <<'EOF'\n{resolv_conf}EOF\n"
                f"sudo cp /tmp/wonderland-resolv {shlex.quote(str(rootfs / 'etc' / 'resolv.conf'))}\n"
                "rm -f /tmp/wonderland-resolv",
            ])

        except Exception as exc:
            return StageResult(self.name, False, str(exc))

        write_stage_state(
            context,
            self.name,
            {
                "network_backend": "systemd-networkd",
                "dhcp": True,
                "ssh_enabled": True,
                "resolved_enabled": False,
                "network_config": str(network_dir / "20-wired.network"),
                "resolv_conf": "static fallback",
            },
        )

        return StageResult(self.name, True, "configured DHCP networking and SSH")
