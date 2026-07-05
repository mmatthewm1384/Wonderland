from __future__ import annotations

from pathlib import Path

from wlknowledge.model import KnowledgeModel
from wlknowledge.scanners.repository import scan_repository


def compile_model(root: Path) -> KnowledgeModel:
    model = KnowledgeModel(stage="phase-1")
    model.repository = scan_repository(root)
    return model.finalize()
