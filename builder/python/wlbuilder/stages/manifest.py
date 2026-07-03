from __future__ import annotations

import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

from wlbuilder.context import BuilderContext
from wlbuilder.native_state import read_state, write_stage_state
from wlbuilder.stages.base import StageResult


class ManifestStage:
    implemented = True
    name = "manifest"
    description = "Generate build manifest from native artifact authority."
    legacy_source = "native manifest"

    def run(self, context: BuilderContext) -> StageResult:
        state = read_state(context)
        convert = state.get("convert", {})
        disk = state.get("disk", {})

        manifest_path = context.manifest_root / "wonderland-os-0.1.1-arm64-development.manifest.json"
        context.manifest_root.mkdir(parents=True, exist_ok=True)

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

        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")

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
