from __future__ import annotations

from pathlib import Path

from wlbuilder.config import load_config
from wlbuilder.config_schema import validate_config
from wlbuilder.migration import stage_mode
from wlbuilder.runtime_context import RuntimeContext
from wlbuilder.stages import default_pipeline


def _write_stage_migration(context: RuntimeContext) -> Path:
    repo_root = context.repo_root
    builder = context.builder
    output = repo_root / "docs" / "builder" / "stage-migration.md"

    with output.open("w", encoding="utf-8") as handle:
        handle.write("# Builder v2 Stage Migration\n\n")
        handle.write("This document is generated from the live Builder v2 stage registry.\n\n")
        handle.write("Regenerate with:\n\n")
        handle.write("```bash\nwl builder docs\n```\n\n")
        handle.write("| Stage | Mode | Implemented | Ready | Legacy Source | Responsibility |\n")
        handle.write("|---|---|---|---|---|---|\n")

        for stage in default_pipeline():
            mode = stage_mode(builder, stage.name)
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


def _write_artifact_authority(context: RuntimeContext) -> Path:
    builder = context.builder
    output = context.repo_root / "docs" / "builder" / "artifact-authority.md"

    artifacts = sorted(
        artifact
        for artifact in builder.output_root.rglob("*")
        if artifact.is_file()
    ) if builder.output_root.exists() else []

    with output.open("w", encoding="utf-8") as handle:
        handle.write("# Builder v2 Artifact Authority\n\n")
        handle.write("Builder v2 canonical artifacts live under:\n\n")
        handle.write("```text\n")
        handle.write(str(builder.output_root))
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


def _write_migration_plan(context: RuntimeContext) -> Path:
    builder = context.builder
    output = context.repo_root / "docs" / "builder" / "migration-plan.md"

    with output.open("w", encoding="utf-8") as handle:
        handle.write("# Builder v2 Migration Plan\n\n")
        handle.write("Generated from the active Builder migration configuration.\n\n")
        handle.write("Inspect with:\n\n")
        handle.write("```bash\nwl builder migration\nwl builder migration --json\n```\n\n")
        handle.write("| Stage | Mode | Implemented | Ready |\n")
        handle.write("|---|---|---|---|\n")

        for stage in default_pipeline():
            mode = stage_mode(builder, stage.name)
            implemented = bool(getattr(stage, "implemented", False))
            ready = mode != "native" or implemented

            handle.write(
                f"| `{stage.name}` | {mode} | "
                f"{str(implemented).lower()} | {str(ready).lower()} |\n"
            )

    return output


def run(context: RuntimeContext) -> int:
    docs_root = context.repo_root / "docs" / "builder"
    docs_root.mkdir(parents=True, exist_ok=True)

    outputs = [
        _write_stage_migration(context),
        _write_config_reference(context.repo_root),
        _write_artifact_authority(context),
        _write_migration_plan(context),
    ]

    for output in outputs:
        print(output)

    return 0
