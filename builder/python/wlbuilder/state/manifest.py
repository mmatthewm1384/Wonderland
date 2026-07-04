from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from wlbuilder.context import BuilderContext


def path(context: BuilderContext, name: str = "manifest.json") -> Path:
    return context.manifest_root / name


def write_manifest(
    context: BuilderContext,
    manifest: dict[str, Any],
    *,
    name: str = "manifest.json",
) -> Path:
    manifest_path = path(context, name)
    manifest_path.parent.mkdir(parents=True, exist_ok=True)

    manifest_path.write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )

    return manifest_path
