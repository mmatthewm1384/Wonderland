from __future__ import annotations

import json
from pathlib import Path

from wlknowledge.model import KnowledgeModel


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")


def render_model_json(model: KnowledgeModel, out_dir: Path) -> Path:
    path = out_dir / "model.json"
    write_json(path, model.to_dict())
    return path


def render_manifest_json(model: KnowledgeModel, knowledge_dir: Path) -> Path:
    data = model.to_dict()

    manifest = {
        "system": data["system"],
        "version": data["version"],
        "stage": data["stage"],
        "generated_at": data["generated_at"],
        "fingerprint": data["fingerprint"],
        "counts": data["counts"],
        "model": "knowledge/generated/model.json",
    }

    path = knowledge_dir / "manifest.json"
    write_json(path, manifest)
    return path
