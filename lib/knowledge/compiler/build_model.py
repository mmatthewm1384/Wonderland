#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import os
import stat
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def rel(root: Path, path: Path) -> str:
    return path.relative_to(root).as_posix()


def is_ignored(path: Path) -> bool:
    ignored = {
        ".git",
        "node_modules",
        ".venv",
        "__pycache__",
        ".build",
        "target",
        "DerivedData",
    }
    return any(part in ignored for part in path.parts)


def files(root: Path):
    for p in root.rglob("*"):
        if p.is_file() and not is_ignored(p):
            yield p


def directories(root: Path):
    for p in root.rglob("*"):
        if p.is_dir() and not is_ignored(p):
            yield p


def git_value(root: Path, args: list[str]) -> str | None:
    try:
        return subprocess.check_output(
            ["git", *args],
            cwd=root,
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
    except Exception:
        return None


def build_model(root: Path) -> dict[str, Any]:
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    all_files = list(files(root))
    all_dirs = list(directories(root))

    bin_dir = root / "bin"
    commands = []
    if bin_dir.exists():
        for p in sorted(bin_dir.iterdir()):
            if p.is_file() and os.access(p, os.X_OK):
                commands.append({
                    "name": p.name,
                    "path": rel(root, p),
                })

    apps_dir = root / "apps"
    applications = []
    if apps_dir.exists():
        for p in sorted(apps_dir.rglob("*")):
            if p.is_dir() and not is_ignored(p):
                app_type = "directory"
                if (p / "Package.swift").exists():
                    app_type = "swift-package"
                elif (p / "src-tauri").exists():
                    app_type = "tauri-app"
                applications.append({
                    "name": p.name,
                    "path": rel(root, p),
                    "type": app_type,
                })

    swift_packages = [
        {"path": rel(root, p)}
        for p in sorted(root.rglob("Package.swift"))
        if not is_ignored(p)
    ]

    tauri_apps = [
        {"path": rel(root, p)}
        for p in sorted(root.rglob("src-tauri"))
        if p.is_dir() and not is_ignored(p)
    ]

    docs = [
        {"path": rel(root, p), "name": p.name}
        for p in sorted(root.rglob("*.md"))
        if not is_ignored(p)
    ]

    decisions = [
        {"path": rel(root, p), "name": p.name}
        for p in sorted(root.rglob("*.md"))
        if not is_ignored(p)
        and (p.name.startswith("ADR-") or "decisions" in p.parts)
    ]

    service_names = {"compose.yml", "docker-compose.yml", "docker-compose.yaml"}
    services = []
    for p in sorted(all_files):
        if p.suffix in {".service", ".timer", ".plist"} or p.name in service_names:
            services.append({
                "name": p.name,
                "path": rel(root, p),
                "type": p.suffix.removeprefix(".") if p.suffix else p.name,
            })

    top_level = [
        {"name": p.name, "path": rel(root, p), "type": "dir" if p.is_dir() else "file"}
        for p in sorted(root.iterdir())
        if p.name != ".git"
    ]

    counts = {
        "files": len(all_files),
        "directories": len(all_dirs),
        "commands": len(commands),
        "applications": len(applications),
        "swift_packages": len(swift_packages),
        "tauri_apps": len(tauri_apps),
        "documentation": len(docs),
        "decisions": len(decisions),
        "services": len(services),
        "shell_files": sum(1 for p in all_files if p.suffix == ".sh" or "/bin/" in p.as_posix()),
        "python_files": sum(1 for p in all_files if p.suffix == ".py"),
        "swift_files": sum(1 for p in all_files if p.suffix == ".swift"),
        "typescript_files": sum(1 for p in all_files if p.suffix in {".ts", ".tsx"}),
    }

    model: dict[str, Any] = {
        "system": "Wonderland Knowledge System",
        "version": "4.0",
        "stage": "knowledge-compiler",
        "generated_at": now,
        "repository": {
            "root": str(root),
            "branch": git_value(root, ["rev-parse", "--abbrev-ref", "HEAD"]),
            "commit": git_value(root, ["rev-parse", "--short", "HEAD"]),
            "top_level": top_level,
        },
        "counts": counts,
        "commands": commands,
        "applications": applications,
        "swift_packages": swift_packages,
        "tauri_apps": tauri_apps,
        "documents": docs,
        "decisions": decisions,
        "services": services,
    }

    fingerprint_input = json.dumps(model, sort_keys=True, separators=(",", ":")).encode()
    model["fingerprint"] = hashlib.sha256(fingerprint_input).hexdigest()[:16]

    return model


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: build_model.py ROOT OUT", file=sys.stderr)
        return 2

    root = Path(sys.argv[1]).resolve()
    out = Path(sys.argv[2]).resolve()
    out.parent.mkdir(parents=True, exist_ok=True)

    model = build_model(root)
    out.write_text(json.dumps(model, indent=2) + "\n")
    print(model["fingerprint"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
