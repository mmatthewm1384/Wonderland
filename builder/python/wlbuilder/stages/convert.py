from __future__ import annotations

import hashlib
import subprocess
from pathlib import Path

from wlbuilder.context import BuilderContext
from wlbuilder.native_state import read_state, write_stage_state
from wlbuilder.stages.base import StageResult


class ConvertStage:
    implemented = True
    name = "convert"
    description = "Convert raw image into QCOW2 artifact and generate checksums."
    requires = ("raw_image",)
    produces = ("qcow2_image", "qcow2_sha256", "checksum_file")
    legacy_source = "native convert"

    def run(self, context: BuilderContext) -> StageResult:
        state = read_state(context)
        disk_state = state.get("disk", {})

        raw_value = disk_state.get("raw_image")
        raw_image = Path(raw_value) if raw_value else self._latest_raw_image(context)

        if raw_image is None or not raw_image.exists():
            return StageResult(self.name, False, "raw image missing")

        qcow2_image = context.qcow2_output / raw_image.with_suffix(".qcow2").name
        checksum_file = context.qcow2_output / f"{qcow2_image.name}.sha256"

        context.qcow2_output.mkdir(parents=True, exist_ok=True)

        result = subprocess.run(
            [
                "qemu-img",
                "convert",
                "-f",
                "raw",
                "-O",
                "qcow2",
                str(raw_image),
                str(qcow2_image),
            ],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        if result.returncode != 0:
            return StageResult(
                self.name,
                False,
                result.stderr.strip() or "qemu-img convert failed",
            )

        digest = sha256_file(qcow2_image)
        checksum_file.write_text(f"{digest}  {qcow2_image.name}\n")

        write_stage_state(
            context,
            self.name,
            {
                "raw_image": str(raw_image),
                "qcow2_image": str(qcow2_image),
                "qcow2_sha256": digest,
                "checksum_file": str(checksum_file),
                "qcow2_size_bytes": qcow2_image.stat().st_size,
            },
        )

        return StageResult(self.name, True, f"converted QCOW2 artifact {qcow2_image}")


    @staticmethod
    def _latest_raw_image(context: BuilderContext) -> Path | None:
        candidates = sorted(
            context.raw_output.glob("*.raw"),
            key=lambda p: p.stat().st_mtime,
            reverse=True,
        )
        return candidates[0] if candidates else None


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()

    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)

    return h.hexdigest()
