from __future__ import annotations

import shlex

from wlbuilder.commands_util import run_command
from wlbuilder.context import BuilderContext
from wlbuilder.native_state import write_stage_state
from wlbuilder.stages.base import StageResult


class IdentityStage:
    implemented = True
    name = "identity"
    description = "Configure system hostname and hosts file."
    requires = ("rootfs",)
    produces = ("hostname", "hostname_path", "hosts_path")
    legacy_source = "build.__main__ identity stage"

    def run(self, context: BuilderContext) -> StageResult:
        rootfs = context.tmp_root / "mnt"
        etc = rootfs / "etc"

        if not rootfs.exists():
            return StageResult(self.name, False, f"rootfs mount missing: {rootfs}")

        if not etc.exists():
            return StageResult(self.name, False, f"/etc missing in rootfs: {etc}")

        hostname = "wonderland"

        hosts = f"""127.0.0.1 localhost
127.0.1.1 {hostname}

::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
"""

        try:
            run_command([
                "bash",
                "-lc",
                f"printf '%s\n' {shlex.quote(hostname)} | sudo tee {shlex.quote(str(etc / 'hostname'))} >/dev/null",
            ])

            run_command([
                "bash",
                "-lc",
                f"cat > /tmp/wonderland-hosts <<'EOF'\n{hosts}EOF\nsudo cp /tmp/wonderland-hosts {shlex.quote(str(etc / 'hosts'))}\nrm -f /tmp/wonderland-hosts",
            ])
        except Exception as exc:
            return StageResult(self.name, False, str(exc))

        write_stage_state(
            context,
            self.name,
            {
                "hostname": hostname,
                "hostname_path": str(etc / "hostname"),
                "hosts_path": str(etc / "hosts"),
            },
        )

        return StageResult(self.name, True, f"configured hostname {hostname}")
