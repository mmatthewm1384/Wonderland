from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from wlknowledge.compiler import compile_model
from wlknowledge.model import KnowledgeModel
from wlknowledge.renderers.json import render_manifest_json, render_model_json
from wlknowledge.renderers.markdown import render_markdown


@dataclass(frozen=True)
class PipelineResult:
    root: Path
    knowledge_dir: Path
    generated_dir: Path
    model: KnowledgeModel
    written_files: list[Path]


class KnowledgePipeline:
    def __init__(self, root: Path) -> None:
        self.root = root.resolve()
        self.knowledge_dir = self.root / "knowledge"
        self.generated_dir = self.knowledge_dir / "generated"

    def scan(self) -> KnowledgeModel:
        return compile_model(self.root)

    def render_json(self, model: KnowledgeModel) -> list[Path]:
        return [
            render_model_json(model, self.generated_dir),
            render_manifest_json(model, self.knowledge_dir),
        ]

    def render_markdown(self, model: KnowledgeModel) -> list[Path]:
        return render_markdown(model, self.generated_dir)

    def build(self) -> PipelineResult:
        model = self.scan()
        written: list[Path] = []
        written.extend(self.render_json(model))
        written.extend(self.render_markdown(model))

        return PipelineResult(
            root=self.root,
            knowledge_dir=self.knowledge_dir,
            generated_dir=self.generated_dir,
            model=model,
            written_files=written,
        )
