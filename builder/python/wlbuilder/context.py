from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import os

from wlbuilder.config import BuilderConfig, load_config, resolve_output_root
from wlbuilder.artifacts import BuildArtifacts
from wlbuilder.native_state import read_state


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
    artifacts: BuildArtifacts


def _resolve_repo_path(repo_root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else repo_root / path


def _resolve_path(repo_root: Path, configured: object, default: Path) -> Path:
    if configured:
        return _resolve_repo_path(repo_root, str(configured))

    default = Path(default).expanduser()
    if default.is_absolute():
        return default

    return repo_root / default


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
        raw_output=_resolve_path(repo_root, paths.get("raw"), output_root / "images" / "raw"),
        qcow2_output=_resolve_path(repo_root, paths.get("qcow2"), output_root / "images" / "qcow2"),
        vmware_output=_resolve_path(repo_root, paths.get("vmware"), output_root / "images" / "vmware"),
        log_root=_resolve_path(repo_root, paths.get("logs"), output_root / "logs"),
        manifest_root=_resolve_path(repo_root, paths.get("manifests"), output_root / "manifests"),
        cache_root=_resolve_path(repo_root, paths.get("cache"), output_root / "cache"),
        tmp_root=_resolve_path(repo_root, paths.get("tmp"), output_root / "tmp"),
        artifacts=BuildArtifacts.from_state(read_state_for_context(repo_root, output_root)),
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


def read_state_for_context(repo_root: Path, output_root: Path) -> dict:
    class _Context:
        pass

    context = _Context()
    context.repo_root = repo_root
    context.tmp_root = output_root / "tmp"

    try:
        return read_state(context)  # type: ignore[arg-type]
    except Exception:
        return {}
