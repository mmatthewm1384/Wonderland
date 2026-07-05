from __future__ import annotations

from pathlib import Path

from wlknowledge.fs import ignored, rel
from wlknowledge.model import Entity


def scan_documents(root: Path) -> list[Entity]:
    return [
        Entity(name=p.name, path=rel(root, p), type="markdown")
        for p in sorted(root.rglob("*.md"))
        if not ignored(p)
    ]


def scan_decisions(root: Path) -> list[Entity]:
    return [
        Entity(name=p.name, path=rel(root, p), type="decision")
        for p in sorted(root.rglob("*.md"))
        if not ignored(p) and (p.name.startswith("ADR-") or "decisions" in p.parts)
    ]
