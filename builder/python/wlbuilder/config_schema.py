from __future__ import annotations

from dataclasses import dataclass

from wlbuilder.config import BuilderConfig


@dataclass(frozen=True, slots=True)
class ConfigIssue:
    field: str
    message: str


REQUIRED_FIELDS = (
    "builder.name",
    "builder.version",
    "system.name",
    "system.version",
    "system.architecture",
    "disk.size",
    "output.root",
)

EXPECTED_MIGRATION_STAGES = (
    "disk",
    "mount",
    "bootstrap",
    "packages",
    "identity",
    "locale",
    "users",
    "networking",
    "bootloader",
    "verify-image",
    "cleanup",
    "convert",
    "manifest",
)

VALID_MIGRATION_MODES = {"native", "legacy", "skip"}


def _get(data: dict, dotted: str):
    value = data

    for part in dotted.split("."):
        if not isinstance(value, dict) or part not in value:
            return None
        value = value[part]

    return value


def validate_config(config: BuilderConfig) -> list[ConfigIssue]:
    data = config.data
    issues: list[ConfigIssue] = []

    for field in REQUIRED_FIELDS:
        value = _get(data, field)
        if value in (None, ""):
            issues.append(ConfigIssue(field, "required field is missing"))

    profiles = data.get("profiles", {})
    default_profile = config.default_profile

    if not isinstance(profiles, dict) or default_profile not in profiles:
        issues.append(
            ConfigIssue(
                "profiles",
                f"default profile {default_profile!r} is not defined",
            )
        )

    migration = data.get("migration", {})
    if not isinstance(migration, dict):
        issues.append(ConfigIssue("migration", "must be a mapping"))
    else:
        for stage in EXPECTED_MIGRATION_STAGES:
            mode = migration.get(stage)
            if mode is None:
                issues.append(ConfigIssue(f"migration.{stage}", "missing migration mode"))
            elif str(mode) not in VALID_MIGRATION_MODES:
                issues.append(
                    ConfigIssue(
                        f"migration.{stage}",
                        f"invalid mode {mode!r}; expected native, legacy, or skip",
                    )
                )

        unknown = sorted(set(migration) - set(EXPECTED_MIGRATION_STAGES))
        for stage in unknown:
            issues.append(ConfigIssue(f"migration.{stage}", "unknown stage"))

    return issues
