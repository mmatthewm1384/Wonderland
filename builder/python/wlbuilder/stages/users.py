from __future__ import annotations

import shlex

from wlbuilder.commands_util import run_command
from wlbuilder.context import BuilderContext
from wlbuilder.native_state import write_stage_state
from wlbuilder.stages.base import StageResult


class UsersStage:
    implemented = True
    name = "users"
    description = "Create default Wonderland user and sudo access."
    legacy_source = "build.__main__ users stage"

    def run(self, context: BuilderContext) -> StageResult:
        rootfs = context.tmp_root / "mnt"

        if not rootfs.exists():
            return StageResult(self.name, False, f"rootfs mount missing: {rootfs}")

        username = "wonderland"
        password = "wonderland"

        try:
            run_command([
                "sudo",
                "chroot",
                str(rootfs),
                "useradd",
                "-m",
                "-s",
                "/bin/bash",
                username,
            ])

            run_command([
                "bash",
                "-lc",
                "printf '%s:%s\n' "
                f"{shlex.quote(username)} {shlex.quote(password)} "
                f"| sudo chroot {shlex.quote(str(rootfs))} chpasswd",
            ])

            run_command([
                "sudo",
                "chroot",
                str(rootfs),
                "usermod",
                "-aG",
                "sudo",
                username,
            ])

            run_command([
                "bash",
                "-lc",
                f"printf '%s\n' '{username} ALL=(ALL) NOPASSWD:ALL' "
                f"| sudo tee {shlex.quote(str(rootfs / 'etc' / 'sudoers.d' / 'wonderland'))} >/dev/null",
            ])

            run_command([
                "sudo",
                "chmod",
                "0440",
                str(rootfs / "etc" / "sudoers.d" / "wonderland"),
            ])

        except Exception as exc:
            return StageResult(self.name, False, str(exc))

        write_stage_state(
            context,
            self.name,
            {
                "username": username,
                "home": f"/home/{username}",
                "sudo": True,
                "password": "development-default",
            },
        )

        return StageResult(self.name, True, f"created user {username}")
