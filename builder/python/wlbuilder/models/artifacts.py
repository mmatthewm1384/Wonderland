from __future__ import annotations

from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any


@dataclass(slots=True)
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

    def to_dict(self) -> dict[str, Any]:
        result: dict[str, Any] = {}
        for key, value in asdict(self).items():
            if value is None:
                continue
            result[key] = str(value) if isinstance(value, Path) else value
        return result
