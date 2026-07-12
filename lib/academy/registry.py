#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path.cwd()
ACADEMY = ROOT / "academy"
REGISTRY_DIR = ACADEMY / "registry"
REGISTRY = REGISTRY_DIR / "chapters.json"

def chapter_id_from_path(path: Path) -> str:
    m = re.search(r"chapter-(\d+)", str(path))
    return m.group(1) if m else ""

def title_from_metadata(chapter_dir: Path) -> str:
    meta = chapter_dir / "metadata.yaml"
    if meta.exists():
        for line in meta.read_text(errors="replace").splitlines():
            if line.lower().startswith("title:"):
                return line.split(":", 1)[1].strip().strip('"').strip("'")
    chapter = chapter_dir / "chapter.md"
    if chapter.exists():
        for line in chapter.read_text(errors="replace").splitlines():
            if line.startswith("# "):
                return line[2:].strip()
    return chapter_dir.name

def discover() -> dict:
    chapters = []
    for chapter_file in sorted(ACADEMY.rglob("chapter.md")):
        chapter_dir = chapter_file.parent
        cid = chapter_id_from_path(chapter_dir)
        rel = chapter_dir.relative_to(ACADEMY).as_posix()
        chapters.append({
            "id": cid,
            "title": title_from_metadata(chapter_dir),
            "status": "draft",
            "version": "0.1.0",
            "path": rel,
            "chapter_file": f"{rel}/chapter.md",
        })

    return {
        "schema": "wonderland.academy.chapters.v1",
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "chapter_count": len(chapters),
        "chapters": chapters,
    }

def validate(data: dict) -> int:
    failures = 0
    seen = set()

    if data.get("schema") != "wonderland.academy.chapters.v1":
        print("FAIL registry schema")
        failures += 1
    else:
        print("PASS registry schema")

    chapters = data.get("chapters")
    if not isinstance(chapters, list):
        print("FAIL registry chapters array")
        return 1

    for ch in chapters:
        cid = ch.get("id", "")
        path = ch.get("path", "")
        cfile = ACADEMY / path / "chapter.md"

        if not cid:
            print(f"FAIL missing chapter id: {path}")
            failures += 1
        elif cid in seen:
            print(f"FAIL duplicate chapter id: {cid}")
            failures += 1
        else:
            seen.add(cid)
            print(f"PASS chapter id: {cid}")

        if cfile.exists():
            print(f"PASS chapter file: {path}/chapter.md")
        else:
            print(f"FAIL missing chapter file: {path}/chapter.md")
            failures += 1

        if ch.get("title"):
            print(f"PASS chapter title: {cid}")
        else:
            print(f"FAIL missing chapter title: {cid}")
            failures += 1

    if failures:
        print("RESULT FAIL")
        return 1

    print("RESULT PASS")
    return 0

def main() -> int:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "help"

    if cmd == "generate":
        REGISTRY_DIR.mkdir(parents=True, exist_ok=True)
        data = discover()
        REGISTRY.write_text(json.dumps(data, indent=2) + "\n")
        print(f"PASS wrote {REGISTRY}")
        print(f"PASS chapters: {data['chapter_count']}")
        return 0

    if cmd == "validate":
        if not REGISTRY.exists():
            print(f"FAIL missing registry: {REGISTRY}")
            return 1
        return validate(json.loads(REGISTRY.read_text()))

    if cmd == "list":
        if not REGISTRY.exists():
            print(f"FAIL missing registry: {REGISTRY}")
            return 1
        data = json.loads(REGISTRY.read_text())
        for ch in data.get("chapters", []):
            print(f"{ch.get('id','')} | {ch.get('status','')} | {ch.get('title','')} | {ch.get('path','')}")
        return 0

    print("Usage: registry.py generate|validate|list", file=sys.stderr)
    return 64

if __name__ == "__main__":
    raise SystemExit(main())
