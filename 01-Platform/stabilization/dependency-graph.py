#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "05-Vault/generated/stabilization/platform-0.4-dependency-graph.json"

SCAN_PATHS = [
    ROOT / "bin",
    ROOT / "01-Platform",
]

COMMAND_PATTERN = re.compile(r"\b(?:bin/)?(wl-[a-zA-Z0-9_-]+)\b")


def scan_file(path: Path) -> dict:
    text = path.read_text(errors="ignore")
    refs = sorted(set(COMMAND_PATTERN.findall(text)))

    return {
        "path": str(path.relative_to(ROOT)),
        "references": refs,
        "reference_count": len(refs),
    }


def main() -> int:
    files = []

    for base in SCAN_PATHS:
        if not base.exists():
            continue

        for path in sorted(base.rglob("*")):
            if not path.is_file():
                continue
            if path.suffix in {".bak", ".pyc"}:
                continue
            if ".bak-" in path.name:
                continue

            try:
                item = scan_file(path)
            except Exception:
                continue

            if item["references"]:
                files.append(item)

    graph = {
        "created_at": datetime.now(timezone.utc).isoformat(),
        "platform": "Wonderland",
        "platform_version": "0.4",
        "destructive_changes": False,
        "files_scanned": len(files),
        "dependency_references": files,
    }

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(graph, indent=2, sort_keys=True) + "\n")

    print("Wonderland Platform 0.4 Dependency Graph")
    print()
    print(f"Files with command references: {len(files)}")
    print(f"Graph: {OUT.relative_to(ROOT)}")
    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
