from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from wlbuilder.config import BuilderConfig


@dataclass(frozen=True, slots=True)
class BuilderContext:
    repo_root: Path
    builder_root: Path
    config: BuilderConfig
    profile: str

    output_root: Path
    raw_output: Path
    qcow2_output: Path
    vmware_output: Path
    log_root: Path
    manifest_root: Path
    cache_root: Path
    tmp_root: Path


def create_context(repo_root: Path, profile: str | None = None) -> BuilderContext:
    from wlbuilder.config import load_config

    config = load_config(repo_root)
    builder_root = repo_root / "builder"

    selected_profile = profile or config.default_profile
    output_root = config.output_root

    return BuilderContext(
        repo_root=repo_root,
        builder_root=builder_root,
        config=config,
        profile=selected_profile,
        output_root=output_root,
        raw_output=output_root / "raw",
        qcow2_output=output_root / "qcow2",
        vmware_output=output_root / "vmware",
        log_root=output_root / "logs",
        manifest_root=output_root / "manifests",
        cache_root=output_root / "cache",
        tmp_root=output_root / "tmp",
    )


def ensure_output_dirs(context: BuilderContext) -> None:
    for path in (
        context.output_root,
        context.raw_output,
        context.qcow2_output,
        context.vmware_output,
        context.log_root,
        context.manifest_root,
        context.cache_root,
        context.tmp_root,
    ):
        path.mkdir(parents=True, exist_ok=True)
