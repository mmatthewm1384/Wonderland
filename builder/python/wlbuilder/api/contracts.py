from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Protocol


@dataclass(frozen=True)
class ArtifactAuthority:
    raw_image: Path | None = None
    qcow2_image: Path | None = None
    vmdk_image: Path | None = None
    manifest: Path | None = None
    mount_root: Path | None = None
    loop_device: str | None = None
    root_partition: str | None = None
    efi_partition: str | None = None


@dataclass(frozen=True)
class StageResultContract:
    name: str
    success: bool
    message: str


class StageContract(Protocol):
    name: str
    implemented: bool
    description: str

    def run(self, context: object) -> StageResultContract:
        ...
