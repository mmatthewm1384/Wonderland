from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass
class BuildArtifacts:
    raw_image: Path | None = None
    qcow2_image: Path | None = None
    vmdk_image: Path | None = None
    manifest: Path | None = None
    mount_root: Path | None = None
    loop_device: str | None = None
    root_partition: str | None = None
    efi_partition: str | None = None


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
