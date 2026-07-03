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

    return issues
