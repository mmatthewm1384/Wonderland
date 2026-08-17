#!/usr/bin/env python3
"""Canonical Wonderland Music Library operations.

Import is transactional: source files are hashed and copied into a private
transaction directory first. The canonical library is changed only after all
sources have passed verification. Staging sources are removed only after the
canonical objects have been independently verified.
"""

from __future__ import annotations

import hashlib
import json
import os
import shutil
import tempfile
from datetime import datetime, timezone
from pathlib import Path

AUDIO_EXTENSIONS = {".mp3", ".m4a", ".flac", ".wav", ".aac", ".ogg", ".opus", ".alac"}


def _paths(root: Path) -> dict[str, Path]:
    base = root / "vault" / "data" / "music"
    return {
        "base": base,
        "library": base / "library",
        "objects": base / "library" / "objects",
        "imports": base / "imports",
        "staging": base / "imports" / "staging",
        "indexes": base / "indexes",
        "exports": base / "exports",
        "vlc": base / "exports" / "vlc",
        "evidence": base / "evidence" / "imports",
    }


def _audio_files(path: Path) -> list[Path]:
    if path.is_file():
        return [path] if path.suffix.lower() in AUDIO_EXTENSIONS else []
    return sorted(p for p in path.rglob("*") if p.is_file() and p.suffix.lower() in AUDIO_EXTENSIONS)


def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def _safe_relative(source: Path, root: Path) -> Path:
    try:
        rel = source.relative_to(root)
    except ValueError:
        rel = Path(source.name)
    parts = [p for p in rel.parts if p not in ("", ".", "..")]
    return Path(*parts) if parts else Path(source.name)


def _ensure(p: dict[str, Path]) -> None:
    for key in ("objects", "staging", "indexes", "vlc", "evidence"):
        p[key].mkdir(parents=True, exist_ok=True)


def init(root: Path) -> dict:
    p = _paths(root)
    _ensure(p)
    return {"status": "PASS", "library": str(p["library"]), "paths": {k: str(v) for k, v in p.items()}}


def status(root: Path) -> dict:
    p = _paths(root)
    files = list(p["objects"].rglob("*") ) if p["objects"].exists() else []
    tracks = sum(1 for x in files if x.is_file())
    staging = sum(1 for x in p["staging"].rglob("*") if x.is_file()) if p["staging"].exists() else 0
    return {"status": "PASS", "tracks": tracks, "staging_files": staging, "library": str(p["library"])}


def verify(root: Path) -> dict:
    p = _paths(root)
    if not p["objects"].exists():
        return {"status": "PASS", "tracks": 0}
    count = 0
    for f in p["objects"].rglob("*"):
        if f.is_file():
            digest = _sha256(f)
            expected = f.name.split("--", 1)[0]
            if len(expected) == 64 and digest != expected:
                raise RuntimeError(f"library integrity failure: {f}")
            count += 1
    return {"status": "PASS", "tracks": count}


def _record(root: Path, txid: str, records: list[dict], source: Path) -> None:
    p = _paths(root)
    evidence = {
        "protocol": "wonderland.music.import/1.0",
        "transaction": txid,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "source": str(source),
        "records": records,
        "status": "COMMITTED",
    }
    out = p["evidence"] / f"{txid}.json"
    out.write_text(json.dumps(evidence, indent=2) + "\n")


def import_path(root: Path, source: Path, cleanup: bool = True) -> dict:
    p = _paths(root)
    _ensure(p)
    source = source.expanduser().resolve()
    files = _audio_files(source)
    if not files:
        raise RuntimeError(f"no supported audio files found: {source}")

    txid = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    tx = Path(tempfile.mkdtemp(prefix=f"{txid}-", dir=p["staging"]))
    records: list[dict] = []
    committed: list[Path] = []

    try:
        # Phase 1: acquire into private transaction staging and verify every copy.
        for src in files:
            rel = _safe_relative(src, source if source.is_dir() else src.parent)
            digest = _sha256(src)
            staged = tx / rel
            staged.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, staged)
            if _sha256(staged) != digest:
                raise RuntimeError(f"staging verification failed: {src}")
            records.append({"source": str(src), "relative": str(rel), "sha256": digest, "size": src.stat().st_size})

        # Phase 2: reserve canonical names and atomically install each object.
        # Content-addressed names make retries idempotent and collisions explicit.
        for rec in records:
            src = tx / rec["relative"]
            target = p["objects"] / f'{rec["sha256"]}--{Path(rec["relative"]).name}'
            if target.exists():
                if _sha256(target) != rec["sha256"]:
                    raise RuntimeError(f"canonical collision/integrity failure: {target}")
                continue
            tmp = target.with_name(f".{target.name}.{txid}.partial")
            shutil.copy2(src, tmp)
            if _sha256(tmp) != rec["sha256"]:
                tmp.unlink(missing_ok=True)
                raise RuntimeError(f"canonical verification failed: {target}")
            os.replace(tmp, target)
            committed.append(target)

        # Phase 3: independent post-commit verification before deleting staging.
        for target in committed:
            if not target.exists() or _sha256(target) != target.name.split("--", 1)[0]:
                raise RuntimeError(f"post-commit verification failed: {target}")

        _record(root, txid, records, source)

        if cleanup:
            # Only remove the transaction staging after the canonical verification.
            shutil.rmtree(tx)
            if tx.exists():
                raise RuntimeError("staging cleanup verification failed")

        return {"status": "PASS", "transaction": txid, "imported": len(records), "cleanup_verified": not tx.exists()}

    except Exception:
        # Never delete the transaction on failure. This preserves recovery material.
        raise


def import_downloads(root: Path, cleanup: bool = True) -> dict:
    return import_path(root, _paths(root)["base"].parent.parent.parent / "vault" / "data" / "torrents" / "downloads", cleanup)


def list_tracks(root: Path) -> list[str]:
    p = _paths(root)
    return [str(f.relative_to(p["objects"])) for f in sorted(p["objects"].rglob("*")) if f.is_file()]


def export_vlc(root: Path, destination: Path | None = None) -> dict:
    p = _paths(root)
    destination = destination or (root / "Shared" / "VLC" / "Music")
    destination.mkdir(parents=True, exist_ok=True)
    exported = 0
    for obj in sorted(p["objects"].rglob("*")) if p["objects"].exists() else []:
        if not obj.is_file():
            continue
        name = obj.name.split("--", 1)[-1]
        target = destination / name
        if target.exists() and _sha256(target) == _sha256(obj):
            continue
        tmp = destination / f".{name}.partial"
        shutil.copy2(obj, tmp)
        if _sha256(tmp) != _sha256(obj):
            tmp.unlink(missing_ok=True)
            raise RuntimeError(f"VLC export verification failed: {target}")
        os.replace(tmp, target)
        exported += 1
    return {"status": "PASS", "export": "vlc", "destination": str(destination), "exported": exported}


def doctor(root: Path) -> dict:
    p = _paths(root)
    result = init(root)
    result["verify"] = verify(root)
    result["status"] = "PASS"
    return result


def execute(root: Path, command: str, args: list[str]) -> dict | list[str]:
    if command == "init":
        return init(root)
    if command == "status":
        return status(root)
    if command == "verify":
        return verify(root)
    if command == "doctor":
        return doctor(root)
    if command == "list":
        return list_tracks(root)
    if command == "import":
        if not args:
            raise SystemExit("usage: wl music import <path>")
        return import_path(root, Path(args[0]))
    if command == "import-downloads":
        return import_downloads(root)
    if command == "export":
        target = Path(args[1]).expanduser() if len(args) > 1 and args[0] == "vlc" else None
        if not args or args[0] != "vlc":
            raise SystemExit("usage: wl music export vlc [destination]")
        return export_vlc(root, target)
    raise SystemExit(f"unsupported music command: {command}")
