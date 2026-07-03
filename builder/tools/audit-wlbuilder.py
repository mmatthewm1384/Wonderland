#!/usr/bin/env python3
from __future__ import annotations

import ast
import json
from pathlib import Path

ROOT = Path("builder/python/wlbuilder")
REPORT = Path("builder/reports/wlbuilder-audit.json")
MD = Path("builder/reports/wlbuilder-audit.md")


def module_name(path: Path) -> str:
    rel = path.relative_to(Path("builder/python")).with_suffix("")
    return ".".join(rel.parts)


def read_ast(path: Path) -> ast.Module:
    return ast.parse(path.read_text(), filename=str(path))


def imports(tree: ast.Module) -> list[str]:
    found: list[str] = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            found.extend(alias.name for alias in node.names)
        elif isinstance(node, ast.ImportFrom) and node.module:
            found.append(node.module)
    return sorted(set(found))


def definitions(tree: ast.Module) -> dict[str, list[str]]:
    classes: list[str] = []
    funcs: list[str] = []

    for node in tree.body:
        if isinstance(node, ast.ClassDef):
            classes.append(node.name)
        elif isinstance(node, ast.FunctionDef):
            funcs.append(node.name)

    return {"classes": classes, "functions": funcs}


def io_markers(text: str) -> list[str]:
    markers = []
    checks = {
        "subprocess": "subprocess",
        "filesystem_write": ".write_text(",
        "filesystem_open": ".open(",
        "mkdir": ".mkdir(",
        "json": "json.",
        "yaml": "yaml.",
        "sudo": "sudo",
        "mount": "mount",
        "losetup": "losetup",
        "chroot": "chroot",
    }
    for name, needle in checks.items():
        if needle in text:
            markers.append(name)
    return markers


def main() -> int:
    modules = []

    for path in sorted(ROOT.rglob("*.py")):
        if "__pycache__" in path.parts:
            continue

        text = path.read_text()
        tree = read_ast(path)

        modules.append(
            {
                "path": str(path),
                "module": module_name(path),
                "imports": imports(tree),
                "definitions": definitions(tree),
                "io_markers": io_markers(text),
            }
        )

    imported_by: dict[str, list[str]] = {m["module"]: [] for m in modules}
    module_set = set(imported_by)

    for m in modules:
        for imp in m["imports"]:
            if imp in module_set:
                imported_by[imp].append(m["module"])

    report = {
        "root": str(ROOT),
        "module_count": len(modules),
        "modules": modules,
        "imported_by": {k: sorted(v) for k, v in imported_by.items() if v},
    }

    REPORT.write_text(json.dumps(report, indent=2) + "\n")

    lines = [
        "# wlbuilder Architecture Audit",
        "",
        f"Module count: **{len(modules)}**",
        "",
        "## Modules",
        "",
    ]

    for m in modules:
        lines.append(f"### `{m['module']}`")
        lines.append("")
        lines.append(f"- Path: `{m['path']}`")
        lines.append(f"- Classes: `{', '.join(m['definitions']['classes']) or 'none'}`")
        lines.append(f"- Functions: `{', '.join(m['definitions']['functions']) or 'none'}`")
        lines.append(f"- I/O markers: `{', '.join(m['io_markers']) or 'none'}`")
        internal_imports = [i for i in m["imports"] if i.startswith("wlbuilder")]
        lines.append(f"- Internal imports: `{', '.join(internal_imports) or 'none'}`")
        users = imported_by.get(m["module"], [])
        lines.append(f"- Imported by: `{', '.join(sorted(users)) or 'none'}`")
        lines.append("")

    MD.write_text("\n".join(lines) + "\n")

    print(f"Wrote {REPORT}")
    print(f"Wrote {MD}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
