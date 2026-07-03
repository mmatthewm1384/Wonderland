from __future__ import annotations

from wlbuilder.models.artifacts import BuildArtifacts


def _profile(value: object = "development") -> str:
    if isinstance(value, str):
        return value
    return str(getattr(value, "profile", "development"))


def artifact_stem(profile: object = "development") -> str:
    return f"wonderland-os-0.1.1-arm64-{_profile(profile)}"


def raw_image_name(profile: object = "development") -> str:
    return f"{artifact_stem(profile)}.raw"


def qcow2_image_name(profile: object = "development") -> str:
    return f"{artifact_stem(profile)}.qcow2"


def manifest_name(profile: object = "development") -> str:
    return f"{artifact_stem(profile)}.manifest.json"
