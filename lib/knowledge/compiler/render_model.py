#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


def md_list(items: list[dict[str, Any]], key: str = "path", limit: int | None = None) -> str:
    selected = items[:limit] if limit else items
    if not selected:
        return "- None detected\n"
    return "\n".join(f"- `{item[key]}`" for item in selected) + "\n"


def table(rows: list[tuple[str, Any]]) -> str:
    out = ["| Metric | Count |", "|---|---:|"]
    out.extend(f"| {name} | {value} |" for name, value in rows)
    return "\n".join(out) + "\n"


def write(path: Path, text: str) -> None:
    path.write_text(text.rstrip() + "\n")


def render(model: dict[str, Any], out: Path) -> None:
    out.mkdir(parents=True, exist_ok=True)

    counts = model["counts"]
    generated = model["generated_at"]

    write(out / "compiler-summary.md", f"""
# Knowledge Compiler Summary

Generated: {generated}

Fingerprint: `{model["fingerprint"]}`

## Repository

- Branch: `{model["repository"].get("branch")}`
- Commit: `{model["repository"].get("commit")}`

## Counts

{table([
    ("Files", counts["files"]),
    ("Directories", counts["directories"]),
    ("Commands", counts["commands"]),
    ("Applications", counts["applications"]),
    ("Swift packages", counts["swift_packages"]),
    ("Tauri apps", counts["tauri_apps"]),
    ("Documentation", counts["documentation"]),
    ("Decisions", counts["decisions"]),
    ("Services", counts["services"]),
])}
""")

    write(out / "commands.md", f"""
# Command Catalog

Generated: {generated}

Executable commands: **{counts["commands"]}**

## Commands

{md_list(model["commands"], "path")}
""")

    app_lines = []
    for app in model["applications"]:
      app_lines.append(f"- `{app['path']}` — {app['type']}")
    write(out / "applications.md", f"""
# Application Catalog

Generated: {generated}

Application directories: **{counts["applications"]}**  
Swift packages: **{counts["swift_packages"]}**  
Tauri apps: **{counts["tauri_apps"]}**

## Applications

{chr(10).join(app_lines) if app_lines else "- None detected"}

## Swift Packages

{md_list(model["swift_packages"], "path")}

## Tauri Apps

{md_list(model["tauri_apps"], "path")}
""")

    write(out / "documentation.md", f"""
# Documentation Catalog

Generated: {generated}

Markdown files: **{counts["documentation"]}**  
Decision records: **{counts["decisions"]}**

## Decision Records

{md_list(model["decisions"], "path")}

## Documents

{md_list(model["documents"], "path", 300)}
""")

    service_lines = []
    for svc in model["services"]:
        service_lines.append(f"- `{svc['path']}` — {svc['type']}")
    write(out / "services.md", f"""
# Service Catalog

Generated: {generated}

Services: **{counts["services"]}**

## Service Files

{chr(10).join(service_lines) if service_lines else "- None detected"}
""")

    write(out / "statistics.md", f"""
# Repository Statistics

Generated: {generated}

{table([
    ("Files", counts["files"]),
    ("Directories", counts["directories"]),
    ("Shell / command files", counts["shell_files"]),
    ("Python files", counts["python_files"]),
    ("Swift files", counts["swift_files"]),
    ("TypeScript files", counts["typescript_files"]),
    ("Markdown files", counts["documentation"]),
])}
""")

    top = "\n".join(f"- `{item['path']}` — {item['type']}" for item in model["repository"]["top_level"])
    write(out / "repository-inventory.md", f"""
# Repository Inventory

Generated: {generated}

## Top-Level Paths

{top}
""")

    graph_nodes = []
    for name, key in [
        ("Commands", "commands"),
        ("Applications", "applications"),
        ("Services", "services"),
        ("Documentation", "documents"),
        ("Decisions", "decisions"),
    ]:
        graph_nodes.append(f"├── {name} ({len(model[key])})")

    write(out / "knowledge-graph.md", f"""
# Knowledge Graph

Generated: {generated}

```text
Wonderland
{chr(10).join(graph_nodes)}
└── Knowledge Compiler
Source Model

knowledge/generated/model.json
""")

catalogs = [
"compiler-summary.md",
"commands.md",
"applications.md",
"documentation.md",
"services.md",
"statistics.md",
"repository-inventory.md",
"knowledge-graph.md",
]

write(out / "index.md", f"""

Wonderland Knowledge Index

Generated: {generated}

Fingerprint: {model["fingerprint"]}

Generated Catalogs

{chr(10).join(f"- {name}" for name in catalogs)}

Source Model

model.json
""")

manifest = {
"system": model["system"],
"version": model["version"],
"stage": model["stage"],
"generated_at": model["generated_at"],
"fingerprint": model["fingerprint"],
"counts": model["counts"],
"model": "knowledge/generated/model.json",
"generated_catalogs": [f"knowledge/generated/{name}" for name in catalogs],
}
(out.parent / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")

def main() -> int:
if len(sys.argv) != 3:
print("Usage: render_model.py MODEL_JSON GENERATED_DIR", file=sys.stderr)
return 2

model = json.loads(Path(sys.argv[1]).read_text())
render(model, Path(sys.argv[2]))
return 0

if name == "main":
raise SystemExit(main())
