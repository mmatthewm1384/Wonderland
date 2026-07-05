from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from wlknowledge.model import Entity, KnowledgeModel
from wlknowledge.renderers.markdown import TEMPLATE_NAMES, template_root


@dataclass(frozen=True)
class ValidationIssue:
    severity: str
    code: str
    message: str


@dataclass(frozen=True)
class ValidationResult:
    issues: list[ValidationIssue]

    @property
    def ok(self) -> bool:
        return not any(issue.severity == "error" for issue in self.issues)

    @property
    def error_count(self) -> int:
        return sum(1 for issue in self.issues if issue.severity == "error")

    @property
    def warning_count(self) -> int:
        return sum(1 for issue in self.issues if issue.severity == "warning")


def _validate_entities(
    root: Path,
    group: str,
    entities: list[Entity],
    issues: list[ValidationIssue],
) -> None:
    seen: set[tuple[str, str]] = set()

    for entity in entities:
        key = (entity.kind, entity.path)

        if key in seen:
            issues.append(
                ValidationIssue(
                    severity="error",
                    code="duplicate-entity",
                    message=f"duplicate {group} entity: {entity.kind} {entity.path}",
                )
            )

        seen.add(key)

        if not entity.name:
            issues.append(
                ValidationIssue(
                    severity="error",
                    code="missing-name",
                    message=f"{group} entity missing name at {entity.path}",
                )
            )

        if not entity.path:
            issues.append(
                ValidationIssue(
                    severity="error",
                    code="missing-path",
                    message=f"{group} entity missing path",
                )
            )
            continue

        if not (root / entity.path).exists():
            issues.append(
                ValidationIssue(
                    severity="warning",
                    code="missing-source-path",
                    message=f"{group} source path missing: {entity.path}",
                )
            )


def validate_model(root: Path, model: KnowledgeModel) -> ValidationResult:
    issues: list[ValidationIssue] = []

    if model.system != "Wonderland Knowledge Engine":
        issues.append(
            ValidationIssue(
                severity="error",
                code="invalid-system",
                message=f"unexpected system name: {model.system}",
            )
        )

    if not model.fingerprint:
        issues.append(
            ValidationIssue(
                severity="error",
                code="missing-fingerprint",
                message="model fingerprint is empty",
            )
        )

    if not model.repository:
        issues.append(
            ValidationIssue(
                severity="error",
                code="missing-repository",
                message="repository metadata is empty",
            )
        )

    for group, entities in {
        "commands": model.commands,
        "applications": model.applications,
        "services": model.services,
        "documents": model.documents,
        "decisions": model.decisions,
    }.items():
        _validate_entities(root, group, entities, issues)

    templates = template_root()
    if not templates.is_dir():
        issues.append(
            ValidationIssue(
                severity="error",
                code="missing-template-root",
                message=f"missing template root: {templates}",
            )
        )
    else:
        for name in TEMPLATE_NAMES:
            path = templates / f"{name}.tpl"
            if not path.is_file():
                issues.append(
                    ValidationIssue(
                        severity="error",
                        code="missing-template",
                        message=f"missing markdown template: {path}",
                    )
                )

    return ValidationResult(issues=issues)


def validate_outputs(root: Path) -> ValidationResult:
    issues: list[ValidationIssue] = []

    required = [
        "knowledge/manifest.json",
        "knowledge/generated/model.json",
        "knowledge/generated/index.md",
        "knowledge/generated/compiler-summary.md",
        "knowledge/generated/commands.md",
        "knowledge/generated/applications.md",
        "knowledge/generated/services.md",
        "knowledge/generated/documentation.md",
        "knowledge/generated/knowledge-graph.md",
    ]

    for item in required:
        if not (root / item).is_file():
            issues.append(
                ValidationIssue(
                    severity="error",
                    code="missing-output",
                    message=f"missing output artifact: {item}",
                )
            )

    return ValidationResult(issues=issues)


def merge_results(*results: ValidationResult) -> ValidationResult:
    issues: list[ValidationIssue] = []
    for result in results:
        issues.extend(result.issues)
    return ValidationResult(issues=issues)
