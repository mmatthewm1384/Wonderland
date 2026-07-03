from __future__ import annotations

import shlex

from wlbuilder.commands_util import run_command
from wlbuilder.context import BuilderContext
from wlbuilder.native_state import write_stage_state
from wlbuilder.stages.base import StageResult


class LocaleStage:
    implemented = True
    name = "locale"
    description = "Configure locale, timezone, and keyboard defaults."
    legacy_source = "build.__main__ locale stage"

    def run(self, context: BuilderContext) -> StageResult:
        rootfs = context.tmp_root / "mnt"
        etc = rootfs / "etc"

        if not rootfs.exists():
            return StageResult(self.name, False, f"rootfs mount missing: {rootfs}")

        if not etc.exists():
            return StageResult(self.name, False, f"/etc missing in rootfs: {etc}")

        locale = "en_US.UTF-8"
        timezone = "UTC"

        try:
            run_command([
                "bash",
                "-lc",
                f"printf '%s\n' {shlex.quote(locale + ' UTF-8')} | sudo tee {shlex.quote(str(etc / 'locale.gen'))} >/dev/null",
            ])

            run_command([
                "bash",
                "-lc",
                f"printf '%s\n' {shlex.quote('LANG=' + locale)} | sudo tee {shlex.quote(str(etc / 'default' / 'locale'))} >/dev/null",
            ])

            run_command([
                "sudo",
                "chroot",
                str(rootfs),
                "locale-gen",
            ])

            run_command([
                "sudo",
                "chroot",
                str(rootfs),
                "update-locale",
                f"LANG={locale}",
            ])

            run_command([
                "sudo",
                "ln",
                "-sf",
                f"/usr/share/zoneinfo/{timezone}",
                str(etc / "localtime"),
            ])

            run_command([
                "bash",
                "-lc",
                f"printf '%s\n' {shlex.quote(timezone)} | sudo tee {shlex.quote(str(etc / 'timezone'))} >/dev/null",
            ])

        except Exception as exc:
            return StageResult(self.name, False, str(exc))

        write_stage_state(
            context,
            self.name,
            {
                "locale": locale,
                "timezone": timezone,
                "rootfs": str(rootfs),
            },
        )

        return StageResult(self.name, True, f"configured locale {locale} timezone {timezone}")
