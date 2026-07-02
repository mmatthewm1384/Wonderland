from __future__ import annotations

import shutil
from pathlib import Path

from wlbuilder.context import BuilderContext


def _artifact_version(context: BuilderContext) -> str:
    data = context.config.data
    return str(data.get("system", {}).get("version") or data.get("version") or "0.1.1")


def _artifact_arch(context: BuilderContext) -> str:
    data = context.config.data
    return str(data.get("system", {}).get("architecture", "arm64"))


def artifact_stem(context: BuilderContext) -> str:
    return f"wonderland-os-{_artifact_version(context)}-{_artifact_arch(context)}-{context.profile}"


def _latest(releases: Path, pattern: str) -> Path | None:
    matches = sorted(
        releases.glob(pattern),
        key=lambda path: path.stat().st_mtime,
        reverse=True,
    )
    return matches[0] if matches else None


def _clear_output(output_dir: Path, suffix: str) -> None:
    for existing in output_dir.glob(f"*.{suffix}"):
        if existing.is_file():
            existing.unlink()


def collect_legacy_artifacts(context: BuilderContext) -> list[Path]:
    releases = context.repo_root / "releases"
    collected: list[Path] = []

    if not releases.is_dir():
        return collected

    stem = artifact_stem(context)

    artifacts = [
        ("*.qcow2", context.qcow2_output, "qcow2", f"{stem}.qcow2"),
        ("*.vmdk", context.vmware_output, "vmdk", f"{stem}.vmdk"),
        ("*.manifest.json", context.manifest_root, "manifest.json", f"{stem}.manifest.json"),
    ]

    for pattern, output_dir, suffix, filename in artifacts:
        source = _latest(releases, pattern)
        if source is None:
            continue

        output_dir.mkdir(parents=True, exist_ok=True)
        _clear_output(output_dir, suffix)

        target = output_dir / filename
        shutil.copy2(source, target)
        collected.append(target)

    return collected
