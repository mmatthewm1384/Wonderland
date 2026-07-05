from __future__ import annotations

from pathlib import Path

from wlknowledge.fs import is_ignored, rel
from wlknowledge.model import Entity


def scan_documents(root: Path) -> list[Entity]:
    documents: list[Entity] = []

    for path in sorted(root.rglob("*.md")):
        if is_ignored(path):
            continue

        documents.append(
            Entity(
                name=path.name,
                path=rel(root, path),
                kind="markdown",
            )
        )

    return documents


def scan_decisions(root: Path) -> list[Entity]:
    decisions: list[Entity] = []

    for path in sorted(root.rglob("*.md")):
        if is_ignored(path):
            continue

        if path.name.startswith("ADR-") or "decisions" in path.parts:
            decisions.append(
                Entity(
                    name=path.name,
                    path=rel(root, path),
                    kind="decision",
                )
            )

    return decisions
