from __future__ import annotations

from pathlib import Path

from wlbuilder.config import load_config
from wlbuilder.config_schema import validate_config
from wlbuilder.context import create_context
from wlbuilder.migration import stage_mode
from wlbuilder.stages import default_pipeline


def _write_stage_migration(repo_root: Path) -> Path:
    output = repo_root / "docs" / "builder" / "stage-migration.md"
    config = load_config(repo_root)
    context = create_context(repo_root)

    with output.open("w", encoding="utf-8") as handle:
        handle.write("# Builder v2 Stage Migration\n\n")
        handle.write("This document is generated from the live Builder v2 stage registry.\n\n")
        handle.write("Regenerate with:\n\n")
        handle.write("```bash\npython3 -m wlbuilder docs\n```\n\n")
        handle.write("| Stage | Mode | Implemented | Ready | Legacy Source | Responsibility |\n")
        handle.write("|---|---|---|---|---|---|\n")

        for stage in default_pipeline():
            mode = stage_mode(context, stage.name)
            implemented = bool(getattr(stage, "implemented", False))
            ready = mode != "native" or implemented

            handle.write(
                f"| `{stage.name}` | {mode} | {str(implemented).lower()} | "
                f"{str(ready).lower()} | "
                f"{getattr(stage, 'legacy_source', '')} | "
                f"{getattr(stage, 'description', '')} |\n"
            )

    return output


def _write_config_reference(repo_root: Path) -> Path:
    output = repo_root / "docs" / "builder" / "config-reference.md"
    config = load_config(repo_root)
    issues = validate_config(config)

    with output.open("w", encoding="utf-8") as handle:
        handle.write("# Builder v2 Config Reference\n\n")
        handle.write("Generated from the active Builder configuration.\n\n")
        handle.write("Inspect with:\n\n")
        handle.write("```bash\nwl builder config\nwl builder config --json\n```\n\n")
        handle.write(f"Config file: `{config.path}`\n\n")
        handle.write(f"Default profile: `{config.default_profile}`\n\n")
        handle.write(f"Valid: `{str(not issues).lower()}`\n\n")

        if issues:
            handle.write("## Issues\n\n")
            for issue in issues:
                handle.write(f"- `{issue.field}`: {issue.message}\n")
        else:
            handle.write("No configuration issues detected.\n")

    return output


def _write_artifact_authority(repo_root: Path) -> Path:
    output = repo_root / "docs" / "builder" / "artifact-authority.md"
    context = create_context(repo_root)

    artifacts = sorted(
        artifact
        for artifact in context.output_root.rglob("*")
        if artifact.is_file()
    )

    with output.open("w", encoding="utf-8") as handle:
        handle.write("# Builder v2 Artifact Authority\n\n")
        handle.write("Builder v2 canonical artifacts live under:\n\n")
        handle.write("```text\n")
        handle.write(str(context.output_root))
        handle.write("/\n```\n\n")
        handle.write("List artifacts with:\n\n")
        handle.write("```bash\nwl builder artifacts\n```\n\n")
        handle.write("The builder creates or collects build outputs into `$WONDERLAND_BUILD_ROOT/`.\n\n")
        handle.write("The release subsystem should publish from `$WONDERLAND_BUILD_ROOT/`, not directly from legacy build locations.\n\n")

        if artifacts:
            handle.write("## Current Artifacts\n\n")
            for artifact in artifacts:
                handle.write(f"- `{artifact}`\n")
        else:
            handle.write("No artifacts currently present.\n")

    return output



def _write_migration_plan(repo_root: Path) -> Path:
    output = repo_root / "docs" / "builder" / "migration-plan.md"
    context = create_context(repo_root)

    with output.open("w", encoding="utf-8") as handle:
        handle.write("# Builder v2 Migration Plan\n\n")
        handle.write("Generated from the active Builder migration configuration.\n\n")
        handle.write("Inspect with:\n\n")
        handle.write("```bash\nwl builder migration\nwl builder migration --json\n```\n\n")
        handle.write("| Stage | Mode | Implemented | Ready |\n")
        handle.write("|---|---|---|---|\n")

        for stage in default_pipeline():
            mode = stage_mode(context, stage.name)
            implemented = bool(getattr(stage, "implemented", False))
            ready = mode != "native" or implemented

            handle.write(
                f"| `{stage.name}` | {mode} | "
                f"{str(implemented).lower()} | {str(ready).lower()} |\n"
            )

    return output

def run(repo_root: Path) -> int:
    docs_root = repo_root / "docs" / "builder"
    docs_root.mkdir(parents=True, exist_ok=True)

    outputs = [
        _write_stage_migration(repo_root),
        _write_config_reference(repo_root),
        _write_artifact_authority(repo_root),
        _write_migration_plan(repo_root),
    ]

    for output in outputs:
        print(output)

    return 0
