from __future__ import annotations

from pathlib import Path

from wlbuilder.stages import default_pipeline


def run(repo_root: Path) -> int:
    docs_root = repo_root / "docs" / "builder"
    docs_root.mkdir(parents=True, exist_ok=True)

    output = docs_root / "stage-migration.md"

    with output.open("w", encoding="utf-8") as handle:
        handle.write("# Builder v2 Stage Migration\n\n")
        handle.write("This document is generated from the live Builder v2 stage registry.\n\n")
        handle.write("Regenerate with:\n\n")
        handle.write("```bash\n")
        handle.write("python3 -m wlbuilder docs\n")
        handle.write("```\n\n")
        handle.write("| Stage | Status | Legacy Source | Responsibility |\n")
        handle.write("|---|---|---|---|\n")

        for stage in default_pipeline():
            status = "native" if getattr(stage, "implemented", False) else "pending"
            legacy_source = getattr(stage, "legacy_source", "")
            description = getattr(stage, "description", "")

            handle.write(
                f"| `{stage.name}` | {status} | {legacy_source} | {description} |\n"
            )

    print(output.relative_to(repo_root))
    return 0
