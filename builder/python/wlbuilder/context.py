from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import os

from wlbuilder.config import BuilderConfig, load_config, resolve_output_root


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


def _resolve_repo_path(repo_root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else repo_root / path


def create_context(repo_root: Path, profile: str | None = None) -> BuilderContext:
    config = load_config(repo_root)
    data = config.data

    builder_root = repo_root / "builder"
    selected_profile = profile or data.get("system", {}).get("profile") or config.default_profile

    output_root = resolve_output_root(repo_root, data)

    paths = data.get("paths", {})

    return BuilderContext(
        repo_root=repo_root,
        builder_root=builder_root,
        config=config,
        profile=str(selected_profile),

        output_root=output_root,
        raw_output=_resolve_repo_path(repo_root, str(paths.get("raw") or output_root / "raw")),
        qcow2_output=_resolve_repo_path(repo_root, str(paths.get("qcow2") or output_root / "qcow2")),
        vmware_output=_resolve_repo_path(repo_root, str(paths.get("vmware") or output_root / "vmware")),
        log_root=_resolve_repo_path(repo_root, str(paths.get("logs") or output_root / "logs")),
        manifest_root=_resolve_repo_path(repo_root, str(paths.get("manifests") or output_root / "manifests")),
        cache_root=_resolve_repo_path(repo_root, str(paths.get("cache") or output_root / "cache")),
        tmp_root=_resolve_repo_path(repo_root, str(paths.get("tmp") or output_root / "tmp")),
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
