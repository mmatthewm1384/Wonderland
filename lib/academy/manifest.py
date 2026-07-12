#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path.cwd()
ACADEMY = ROOT / "academy"
REGISTRY = ACADEMY / "registry" / "chapters.json"

EXCLUDE_DIRS = {".git", "__pycache__", ".DS_Store"}
BINARY_EXTS = {
    ".png", ".jpg", ".jpeg", ".webp", ".gif", ".svg", ".pdf",
    ".epub", ".zip", ".ico", ".icns"
}

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def is_text(path: Path) -> bool:
    if path.suffix.lower() in BINARY_EXTS:
        return False
    try:
        path.read_text(errors="strict")
        return True
    except UnicodeDecodeError:
        return False

def word_count(path: Path) -> int:
    if not path.exists() or not is_text(path):
        return 0
    text = path.read_text(errors="replace")
    return len(re.findall(r"\b[\w'-]+\b", text))

def file_inventory(chapter_dir: Path) -> list[dict]:
    files = []
    for path in sorted(chapter_dir.rglob("*")):
        if not path.is_file():
            continue
        if path.name == "manifest.json":
            continue
        if any(part in EXCLUDE_DIRS for part in path.parts):
            continue
        rel = path.relative_to(chapter_dir).as_posix()
        files.append({
            "path": rel,
            "bytes": path.stat().st_size,
            "sha256": sha256(path),
            "kind": "text" if is_text(path) else "binary",
        })
    return files

def count_files(chapter_dir: Path, dirname: str) -> int:
    d = chapter_dir / dirname
    if not d.exists():
        return 0
    return sum(1 for p in d.rglob("*") if p.is_file())

def image_count(chapter_dir: Path) -> int:
    return sum(
        1 for p in chapter_dir.rglob("*")
        if p.is_file() and p.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp", ".gif", ".svg"}
    )

def load_registry() -> dict:
    if not REGISTRY.exists():
        raise SystemExit(f"FAIL missing registry: {REGISTRY}")
    return json.loads(REGISTRY.read_text())

def chapter_from_registry(chapter_id: str | None = None) -> list[dict]:
    registry = load_registry()
    chapters = registry.get("chapters", [])
    if chapter_id:
        chapters = [c for c in chapters if c.get("id") == chapter_id]
        if not chapters:
            raise SystemExit(f"FAIL unknown chapter id: {chapter_id}")
    return chapters

def generate_for(ch: dict) -> Path:
    chapter_dir = ACADEMY / ch["path"]
    chapter_file = chapter_dir / "chapter.md"

    if not chapter_file.exists():
        raise SystemExit(f"FAIL missing chapter.md: {chapter_dir}")

    files = file_inventory(chapter_dir)

    manifest = {
        "schema": "wonderland.academy.manifest.v1",
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "chapter": {
            "id": ch.get("id", ""),
            "title": ch.get("title", ""),
            "status": ch.get("status", "draft"),
            "version": ch.get("version", "0.1.0"),
            "path": ch.get("path", ""),
        },
        "counts": {
            "words": word_count(chapter_file),
            "files": len(files),
            "images": image_count(chapter_dir),
            "diagrams": count_files(chapter_dir, "diagrams"),
            "labs": count_files(chapter_dir, "labs"),
            "quizzes": count_files(chapter_dir, "quizzes"),
            "references": count_files(chapter_dir, "references"),
            "glossary": count_files(chapter_dir, "glossary"),
            "codex": count_files(chapter_dir, "codex"),
            "handbook": count_files(chapter_dir, "handbook"),
        },
        "files": files,
    }

    out = chapter_dir / "manifest.json"
    out.write_text(json.dumps(manifest, indent=2) + "\n")
    return out

def validate_manifest(path: Path) -> int:
    failures = 0

    if not path.exists():
        print(f"FAIL missing manifest: {path}")
        return 1

    data = json.loads(path.read_text())
    chapter_dir = path.parent

    if data.get("schema") == "wonderland.academy.manifest.v1":
        print(f"PASS manifest schema: {chapter_dir}")
    else:
        print(f"FAIL manifest schema: {chapter_dir}")
        failures += 1

    for item in data.get("files", []):
        f = chapter_dir / item["path"]
        if not f.exists():
            print(f"FAIL manifest file missing: {item['path']}")
            failures += 1
            continue

        actual = sha256(f)
        if actual == item.get("sha256"):
            print(f"PASS checksum: {item['path']}")
        else:
            print(f"FAIL checksum drift: {item['path']}")
            failures += 1

    expected_count = sum(
        1 for p in chapter_dir.rglob("*")
        if p.is_file()
        and ".git" not in p.parts
        and p.name != "manifest.json"
    )
    manifest_count = len(data.get("files", []))

    if expected_count == manifest_count:
        print(f"PASS manifest file count: {manifest_count}")
    else:
        print(f"FAIL manifest file count: expected {expected_count}, manifest {manifest_count}")
        failures += 1

    return 1 if failures else 0

def main() -> int:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "help"
    chapter_id = sys.argv[2] if len(sys.argv) > 2 else None

    if cmd == "generate":
        failures = 0
        for ch in chapter_from_registry(chapter_id):
            try:
                out = generate_for(ch)
                print(f"PASS wrote {out}")
            except SystemExit as e:
                print(e)
                failures += 1
        print("RESULT PASS" if failures == 0 else "RESULT FAIL")
        return 0 if failures == 0 else 1

    if cmd == "validate":
        failures = 0
        for ch in chapter_from_registry(chapter_id):
            path = ACADEMY / ch["path"] / "manifest.json"
            failures += validate_manifest(path)
        print("RESULT PASS" if failures == 0 else "RESULT FAIL")
        return 0 if failures == 0 else 1

    if cmd == "summary":
        for ch in chapter_from_registry(chapter_id):
            path = ACADEMY / ch["path"] / "manifest.json"
            if not path.exists():
                print(f"FAIL missing manifest: {path}")
                return 1
            data = json.loads(path.read_text())
            counts = data["counts"]
            meta = data["chapter"]
            print(
                f"{meta['id']} | {meta['status']} | "
                f"{counts['words']} words | {counts['files']} files | "
                f"{counts['labs']} labs | {counts['quizzes']} quizzes | "
                f"{meta['title']}"
            )
        return 0

    print("Usage: manifest.py generate|validate|summary [chapter_id]", file=sys.stderr)
    return 64

if __name__ == "__main__":
    raise SystemExit(main())
