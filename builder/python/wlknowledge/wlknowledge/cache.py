from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import hashlib
import json


CACHE_VERSION = "1.1"


@dataclass(frozen=True)
class CacheStatus:
    path: Path
    exists: bool
    hit: bool
    fingerprint: str
    previous_fingerprint: str | None


def repository_fingerprint(root: Path) -> str:
    digest = hashlib.sha256()

    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue

        if ".git" in path.parts:
            continue

        if "knowledge" in path.parts and "packages" in path.parts:
            continue

        rel = path.relative_to(root).as_posix()
        digest.update(rel.encode("utf-8"))
        digest.update(b"\0")

        try:
            stat = path.stat()
        except OSError:
            continue

        digest.update(str(stat.st_size).encode("utf-8"))
        digest.update(b"\0")
        digest.update(str(int(stat.st_mtime)).encode("utf-8"))
        digest.update(b"\0")

    return digest.hexdigest()[:16]


def cache_path(root: Path) -> Path:
    return root / "knowledge" / ".cache" / "wke-cache.json"


def read_cache(root: Path) -> dict | None:
    path = cache_path(root)

    if not path.is_file():
        return None

    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return None


def write_cache(root: Path, fingerprint: str, model_fingerprint: str) -> Path:
    path = cache_path(root)
    path.parent.mkdir(parents=True, exist_ok=True)

    data = {
        "version": CACHE_VERSION,
        "repository_fingerprint": fingerprint,
        "model_fingerprint": model_fingerprint,
    }

    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path


def check_cache(root: Path) -> CacheStatus:
    path = cache_path(root)
    current = repository_fingerprint(root)
    previous = read_cache(root)

    previous_fingerprint = None
    if previous:
        previous_fingerprint = previous.get("repository_fingerprint")

    return CacheStatus(
        path=path,
        exists=path.is_file(),
        hit=previous_fingerprint == current,
        fingerprint=current,
        previous_fingerprint=previous_fingerprint,
    )
