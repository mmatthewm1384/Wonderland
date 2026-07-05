from __future__ import annotations

from pathlib import Path

from wlknowledge.model import Entity, KnowledgeModel


TEMPLATE_NAMES = [
    "index.md",
    "compiler-summary.md",
    "commands.md",
    "applications.md",
    "services.md",
    "documentation.md",
    "knowledge-graph.md",
]


def package_root() -> Path:
    return Path(__file__).resolve().parents[2]


def template_root() -> Path:
    return package_root() / "templates" / "markdown"


def entity_list(items: list[Entity], limit: int | None = None) -> str:
    selected = items if limit is None else items[:limit]

    if not selected:
        return "- None detected"

    return "\n".join(f"- `{item.path}` — {item.kind}" for item in selected)


def knowledge_graph(model: KnowledgeModel) -> str:
    return "\n".join(
        [
            "Wonderland",
            f"├── Commands ({model.counts['commands']})",
            f"├── Applications ({model.counts['applications']})",
            f"├── Services ({model.counts['services']})",
            f"├── Documents ({model.counts['documents']})",
            f"├── Decisions ({model.counts['decisions']})",
            "└── Knowledge Engine",
        ]
    )


def context_for_model(model: KnowledgeModel) -> dict[str, str]:
    return {
        "generated_at": model.generated_at,
        "fingerprint": model.fingerprint,
        "commands_count": str(model.counts["commands"]),
        "applications_count": str(model.counts["applications"]),
        "services_count": str(model.counts["services"]),
        "documents_count": str(model.counts["documents"]),
        "decisions_count": str(model.counts["decisions"]),
        "commands": entity_list(model.commands),
        "applications": entity_list(model.applications),
        "services": entity_list(model.services),
        "decisions": entity_list(model.decisions),
        "documents": entity_list(model.documents, limit=300),
        "knowledge_graph": knowledge_graph(model),
    }


def render_template(template: str, context: dict[str, str]) -> str:
    output = template

    for key, value in context.items():
        output = output.replace("{{" + key + "}}", value)

    return output.rstrip() + "\n"


def render_markdown(model: KnowledgeModel, generated_dir: Path) -> list[Path]:
    generated_dir.mkdir(parents=True, exist_ok=True)

    root = template_root()
    context = context_for_model(model)
    written: list[Path] = []

    for name in TEMPLATE_NAMES:
        template_path = root / f"{name}.tpl"

        if not template_path.is_file():
            raise FileNotFoundError(f"missing template: {template_path}")

        rendered = render_template(
            template_path.read_text(encoding="utf-8"),
            context,
        )

        output_path = generated_dir / name
        output_path.write_text(rendered, encoding="utf-8")
        written.append(output_path)

    return written
