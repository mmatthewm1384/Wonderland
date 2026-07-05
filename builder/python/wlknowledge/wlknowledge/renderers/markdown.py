from __future__ import annotations

from pathlib import Path
from wlknowledge.model import Entity, KnowledgeModel


def bullet(items: list[Entity], limit: int | None = None) -> str:
    selected = items[:limit] if limit else items
    if not selected:
        return "- None detected\n"
    return "\n".join(f"- `{i.path}` — {i.type}" for i in selected) + "\n"


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.strip() + "\n")


def render_markdown(model: KnowledgeModel, out: Path) -> None:
    data = model.to_dict()
    out.mkdir(parents=True, exist_ok=True)

    write(out / "compiler-summary.md", f"""
# Wonderland Knowledge Engine Summary

Generated: {model.generated_at}

Fingerprint: `{model.fingerprint}`

## Counts

| Metric | Count |
|---|---:|
| Commands | {len(model.commands)} |
| Applications | {len(model.applications)} |
| Services | {len(model.services)} |
| Documents | {len(model.documents)} |
| Decisions | {len(model.decisions)} |
""")

    write(out / "commands.md", f"""
# Command Catalog

Generated: {model.generated_at}

## Commands

{bullet(model.commands)}
""")

    write(out / "applications.md", f"""
# Application Catalog

Generated: {model.generated_at}

## Applications

{bullet(model.applications)}
""")

    write(out / "services.md", f"""
# Service Catalog

Generated: {model.generated_at}

## Services

{bullet(model.services)}
""")

    write(out / "documentation.md", f"""
# Documentation Catalog

Generated: {model.generated_at}

## Decisions

{bullet(model.decisions)}

## Documents

{bullet(model.documents, 300)}
""")

    write(out / "knowledge-graph.md", f"""
# Knowledge Graph

Generated: {model.generated_at}

```text
Wonderland
├── Commands ({len(model.commands)})
├── Applications ({len(model.applications)})
├── Services ({len(model.services)})
├── Documents ({len(model.documents)})
├── Decisions ({len(model.decisions)})
└── Knowledge Engine
""")

write(out / "index.md", f"""
Wonderland Knowledge Index

Generated: {model.generated_at}

Fingerprint: {model.fingerprint}

Generated
compiler-summary.md
commands.md
applications.md
services.md
documentation.md
knowledge-graph.md
model.json
""")
