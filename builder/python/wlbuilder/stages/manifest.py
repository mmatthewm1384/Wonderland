from __future__ import annotations

import subprocess
from datetime import datetime, timezone
from pathlib import Path

from wlbuilder.context import BuilderContext
from wlbuilder.native_state import read_state, write_stage_state
from wlbuilder.stages.base import StageResult
from wlbuilder.state.manifest import write_manifest


class ManifestStage:
    implemented = True
    name = "manifest"
    description = "Generate build manifest from native artifact authority."
    legacy_source = "native manifest"

    def run(self, context: BuilderContext) -> StageResult:
        state = read_state(context)
        convert = state.get("convert", {})
        disk = state.get("disk", {})

        manifest_name = "wonderland-os-0.1.1-arm64-development.manifest.json"

        manifest = {
            "schema": "wonderland.builder.manifest.v2",
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "profile": context.profile,
            "repo_root": str(context.repo_root),
            "output_root": str(context.output_root),
            "git_commit": git_commit(context.repo_root),
            "raw_image": disk.get("raw_image"),
            "qcow2_image": convert.get("qcow2_image"),
            "qcow2_sha256": convert.get("qcow2_sha256"),
            "stages": state,
        }

        manifest_path = write_manifest(context, manifest, name=manifest_name)

        write_stage_state(
            context,
            self.name,
            {
                "manifest": str(manifest_path),
            },
        )

        return StageResult(self.name, True, f"wrote manifest {manifest_path}")


def git_commit(repo_root: Path) -> str | None:
    result = subprocess.run(
        ["git", "-C", str(repo_root), "rev-parse", "--short", "HEAD"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip()
