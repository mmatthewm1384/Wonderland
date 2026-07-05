from future import annotations

import json
from pathlib import Path

from wlknowledge.model import KnowledgeModel

def render_json(model: KnowledgeModel, out: Path) -> None:
out.mkdir(parents=True, exist_ok=True)

data = model.to_dict()
(out / "model.json").write_text(json.dumps(data, indent=2) + "\n")

manifest = {
    "system": data["system"],
    "version": data["version"],
    "stage": data["stage"],
    "generated_at": data["generated_at"],
    "fingerprint": data["fingerprint"],
    "counts": data["counts"],
    "model": "knowledge/generated/model.json",
}
(out.parent / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")

