from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from .context import AcademyContext


CHAPTER_REGISTRY_CANDIDATES = (
    "academy/registry/chapters.json",
    "academy/chapter-registry.json",
    "academy/registry.json",
    "vault/05-Registry/academy/chapters.json",
    "vault/05-Registry/academy.json",
)

LESSON_REGISTRY_CANDIDATES = (
    "academy/registry/lessons.json",
    "academy/lesson-registry.json",
    "vault/05-Registry/academy/lessons.json",
)


def first_existing(
    context: AcademyContext,
    candidates: tuple[str, ...],
) -> Path | None:
    for relative in candidates:
        path = context.root / relative

        if path.is_file():
            return path

    return None


def load_json(path: Path) -> Any:
    content = path.read_text()

    if not content.strip():
        raise ValueError(f"empty JSON document: {path}")

    return json.loads(content)


def collection_count(payload: Any) -> int:
    if isinstance(payload, list):
        return len(payload)

    if isinstance(payload, dict):
        for key in (
            "chapters",
            "lessons",
            "entries",
            "items",
            "registry",
        ):
            value = payload.get(key)

            if isinstance(value, list):
                return len(value)

            if isinstance(value, dict):
                return len(value)

        metadata = {
            "schema_version",
            "version",
            "generated_at",
            "result",
            "status",
        }

        return len(
            [
                key
                for key in payload
                if key not in metadata
            ]
        )

    return 0


def discover_lesson_files(
    context: AcademyContext,
) -> list[Path]:
    """
    Return the canonical Academy lesson Markdown collection.

    This function is authoritative for registry generation, verification,
    certification, and future Academy tooling.
    """
    excluded_directory_names = {
        ".git",
        "__pycache__",
        ".pytest_cache",
        "registry",
        "build",
        "dist",
        "generated",
    }

    return sorted(
        path
        for path in context.academy_root.rglob("*.md")
        if path.is_file()
        and path.name.lower() != "readme.md"
        and not any(
            part in excluded_directory_names
            for part in path.relative_to(
                context.academy_root
            ).parts[:-1]
        )
    )
