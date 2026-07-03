from __future__ import annotations

from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any


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

    qcow2_sha256: str | None = None
    build_id: str | None = None
    cleanup_complete: bool = False

    @classmethod
    def from_state(cls, state: dict[str, Any]) -> "BuildArtifacts":
        disk = state.get("disk", {})
        mount = state.get("mount", {})
        convert = state.get("convert", {})
        manifest = state.get("manifest", {})
        cleanup = state.get("cleanup", {})

        return cls(
            raw_image=_path(disk.get("raw_image")),
            qcow2_image=_path(convert.get("qcow2_image")),
            manifest=_path(manifest.get("manifest")),
            mount_root=_path(mount.get("mount_root") or mount.get("rootfs")),
            loop_device=mount.get("loop"),
            root_partition=mount.get("root_partition"),
            efi_partition=mount.get("efi_partition"),
            qcow2_sha256=convert.get("qcow2_sha256"),
            cleanup_complete=not bool(cleanup.get("remaining_mounts")),
        )

    def to_state(self) -> dict[str, Any]:
        return {
            key: str(value) if isinstance(value, Path) else value
            for key, value in asdict(self).items()
            if value is not None
        }

    def require_raw_image(self) -> Path:
        if self.raw_image is None:
            raise ValueError("artifact raw_image is not set")
        return self.raw_image

    def require_mount_root(self) -> Path:
        if self.mount_root is None:
            raise ValueError("artifact mount_root is not set")
        return self.mount_root

    def require_loop_device(self) -> str:
        if not self.loop_device:
            raise ValueError("artifact loop_device is not set")
        return self.loop_device


def _path(value: object) -> Path | None:
    if not value:
        return None
    return Path(str(value))


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
