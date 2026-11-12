#!/usr/bin/env python3
"""Wonderland YTMusic acquisition pipeline; standard-library orchestration."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import tomllib
import uuid
from pathlib import Path

APP_ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = APP_ROOT / "config" / "config.toml"


def utc_now() -> str:
    return dt.datetime.now(dt.UTC).isoformat()


def load_config() -> dict:
    with CONFIG_PATH.open("rb") as f:
        cfg = tomllib.load(f)
    for key in ("incoming_dir", "staging_dir", "manifest_dir", "evidence_dir", "quarantine_dir"):
        p = Path(cfg[key])
        cfg[key] = p if p.is_absolute() else APP_ROOT / p
    return cfg


def ensure_layout(cfg: dict) -> None:
    for key in ("incoming_dir", "staging_dir", "manifest_dir", "evidence_dir", "quarantine_dir"):
        cfg[key].mkdir(parents=True, exist_ok=True)


def event(cfg: dict, kind: str, **fields) -> None:
    record = {"timestamp": utc_now(), "event": kind, **fields}
    path = cfg["evidence_dir"] / "events.jsonl"
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(record, sort_keys=True) + "\n")
        f.flush()
        os.fsync(f.fileno())


def write_json_atomic(path: Path, obj: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + f".tmp.{uuid.uuid4().hex}")
    data = json.dumps(obj, indent=2, sort_keys=True) + "\n"
    with tmp.open("x", encoding="utf-8") as f:
        f.write(data)
        f.flush()
        os.fsync(f.fileno())
    os.replace(tmp, path)


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def safe_stem(value: str, max_len: int) -> str:
    value = re.sub(r'[\\/:*?"<>|\x00-\x1f]', "_", value).strip(" .")
    value = re.sub(r"\s+", " ", value) or "untitled"
    return value[:max_len].rstrip(" .") or "untitled"


def tool_path(name: str) -> str:
    found = shutil.which(name)
    if not found:
        raise RuntimeError(f"Required executable not found on PATH: {name}")
    return found


def probe(path: Path) -> dict:
    cmd = [
        tool_path("ffprobe"),
        "-v",
        "error",
        "-show_format",
        "-show_streams",
        "-of",
        "json",
        str(path),
    ]
    result = subprocess.run(cmd, check=True, capture_output=True, text=True)
    data = json.loads(result.stdout)
    audio = [s for s in data.get("streams", []) if s.get("codec_type") == "audio"]
    if not audio:
        raise RuntimeError("ffprobe found no audio stream")
    fmt = data.get("format", {})
    return {
        "format_name": fmt.get("format_name"),
        "duration": fmt.get("duration"),
        "size": fmt.get("size"),
        "audio_streams": [
            {
                k: s.get(k)
                for k in ("codec_name", "sample_rate", "channels", "channel_layout", "bit_rate")
            }
            for s in audio
        ],
        "tags": fmt.get("tags", {}),
    }


def ytdlp_command(cfg: dict, url: str, work: Path, collection: bool) -> list[str]:
    cmd = [
        tool_path("yt-dlp"),
        "--ignore-config",
        "--no-overwrites",
        "--continue",
        "--retries",
        "10",
        "--fragment-retries",
        "10",
        "--extractor-retries",
        "3",
        "--format",
        cfg["format"],
        "--output",
        str(work / "%(title).180B [%(id)s].%(ext)s"),
        "--print",
        "after_move:filepath",
        "--write-info-json",
        "--embed-metadata",
        "--embed-thumbnail",
        "--no-simulate",
    ]
    if not collection:
        cmd.append("--no-playlist")
    browser = cfg.get("cookies_from_browser", "").strip()
    if browser:
        # Passed only to the child process; never persisted in logs/manifests.
        cmd.extend(["--cookies-from-browser", browser])
    cmd.append(url)
    return cmd


def acquire(cfg: dict, url: str, kind: str) -> int:
    ensure_layout(cfg)
    job_id = dt.datetime.now().strftime("%Y%m%dT%H%M%S") + "-" + uuid.uuid4().hex[:8]
    work = Path(tempfile.mkdtemp(prefix=f"{job_id}.", dir=cfg["staging_dir"]))
    manifest_path = cfg["manifest_dir"] / f"{job_id}.json"
    manifest = {
        "schema": "wonderland.ytmusic.job.v1",
        "job_id": job_id,
        "kind": kind,
        "source_url": url,
        "started_at": utc_now(),
        "state": "running",
        "staging_directory": str(work),
        "artifacts": [],
    }
    write_json_atomic(manifest_path, manifest)
    event(cfg, "acquisition_started", job_id=job_id, kind=kind)
    cmd = ytdlp_command(cfg, url, work, collection=(kind != "track"))
    print("Running yt-dlp; credentials and cookies are not logged.")
    try:
        proc = subprocess.run(cmd, check=False, text=True)
        if proc.returncode != 0:
            manifest.update(state="failed", finished_at=utc_now(), exit_code=proc.returncode)
            write_json_atomic(manifest_path, manifest)
            event(cfg, "acquisition_failed", job_id=job_id, exit_code=proc.returncode)
            print(
                f"FAIL: yt-dlp exited {proc.returncode}; staging retained: {work}", file=sys.stderr
            )
            return proc.returncode

        candidates = sorted(
            p
            for p in work.iterdir()
            if p.is_file() and p.suffix.lower() not in (".json", ".jpg", ".jpeg", ".png", ".webp")
        )
        if not candidates:
            raise RuntimeError("yt-dlp completed but no media files were found")

        promoted = []
        for src in candidates:
            metadata = probe(src)
            digest = sha256(src)
            ext = src.suffix.lower()
            title = src.stem
            dest_name = safe_stem(title, int(cfg["max_filename_length"])) + ext
            dest = cfg["incoming_dir"] / dest_name

            # Content-address duplicate detection across existing incoming media.
            duplicate = None
            for existing in cfg["incoming_dir"].iterdir():
                if existing.is_file() and existing.suffix.lower() == ext:
                    if sha256(existing) == digest:
                        duplicate = existing
                        break
            if duplicate:
                event(cfg, "duplicate_noop", job_id=job_id, sha256=digest, existing=str(duplicate))
                promoted.append(
                    {
                        "sha256": digest,
                        "path": str(duplicate),
                        "result": "duplicate_noop",
                        "probe": metadata,
                    }
                )
                continue

            # Atomic no-clobber promotion: hard-link fails if destination exists.
            counter = 0
            while True:
                candidate = (
                    dest
                    if counter == 0
                    else dest.with_name(f"{dest.stem} ({counter}){dest.suffix}")
                )
                try:
                    os.link(src, candidate)
                    dest = candidate
                    break
                except FileExistsError:
                    counter += 1
                except OSError:
                    # Same-volume staging/incoming should permit hard links. Fail
                    # closed rather than falling back to an overwrite-capable move.
                    raise
            promoted.append(
                {"sha256": digest, "path": str(dest), "result": "promoted", "probe": metadata}
            )
            event(cfg, "artifact_promoted", job_id=job_id, sha256=digest, path=str(dest))

        manifest.update(state="completed", finished_at=utc_now(), artifacts=promoted)
        write_json_atomic(manifest_path, manifest)
        event(cfg, "acquisition_completed", job_id=job_id, artifact_count=len(promoted))
        print(f"PASS: job {job_id}; {len(promoted)} artifact(s) processed")
        return 0
    except Exception as exc:
        manifest.update(state="verification_failed", finished_at=utc_now(), error=str(exc))
        write_json_atomic(manifest_path, manifest)
        event(cfg, "acquisition_verification_failed", job_id=job_id, error=str(exc))
        print(f"FAIL: {exc}; staging retained: {work}", file=sys.stderr)
        return 1


def verify(cfg: dict) -> int:
    ensure_layout(cfg)
    failures = 0
    count = 0
    for path in sorted(cfg["incoming_dir"].iterdir()):
        if not path.is_file():
            continue
        count += 1
        try:
            info = probe(path)
            digest = sha256(path)
            print(
                f"PASS {path.name} sha256={digest} "
                f"codec={info['audio_streams'][0].get('codec_name')}"
            )
        except Exception as exc:
            failures += 1
            print(f"FAIL {path}: {exc}")
    print(f"SUMMARY files={count} failures={failures}")
    event(cfg, "library_verification", files=count, failures=failures)
    return 1 if failures else 0


def audit(cfg: dict) -> int:
    ensure_layout(cfg)
    journal = cfg["evidence_dir"] / "events.jsonl"
    if not journal.exists():
        print("PASS: no events recorded yet")
        return 0
    count = 0
    errors = 0
    with journal.open(encoding="utf-8") as f:
        for number, line in enumerate(f, 1):
            try:
                row = json.loads(line)
                if "timestamp" not in row or "event" not in row:
                    raise ValueError("required event fields missing")
                count += 1
            except Exception as exc:
                errors += 1
                print(f"FAIL journal line {number}: {exc}")
    print(f"SUMMARY valid_events={count} invalid_lines={errors}")
    return 1 if errors else 0


def recover(cfg: dict) -> int:
    ensure_layout(cfg)
    found = 0
    for path in sorted(cfg["manifest_dir"].glob("*.json")):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except Exception as exc:
            print(f"FAIL unreadable manifest {path}: {exc}")
            continue
        if data.get("state") in ("running", "failed", "verification_failed"):
            found += 1
            print(
                f"REVIEW job={data.get('job_id')} state={data.get('state')} "
                f"staging={data.get('staging_directory')}"
            )
    print(f"SUMMARY jobs_requiring_review={found}; no files modified")
    return 0


def status(cfg: dict) -> int:
    print(f"Subsystem: {APP_ROOT}")
    for key in ("incoming_dir", "staging_dir", "manifest_dir", "evidence_dir", "quarantine_dir"):
        p = cfg[key]
        print(f"{key}: {p} (exists={p.exists()})")
    print(f"yt-dlp: {shutil.which('yt-dlp') or 'MISSING'}")
    print(f"ffprobe: {shutil.which('ffprobe') or 'MISSING'}")
    return 0


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(prog="ytmusic")
    sub = parser.add_subparsers(dest="command", required=True)
    for name in ("acquire", "playlist", "album"):
        p = sub.add_parser(name)
        p.add_argument("url")
    for name in ("verify", "audit", "recover", "status"):
        sub.add_parser(name)
    args = parser.parse_args(argv)
    try:
        cfg = load_config()
        if args.command in ("acquire", "playlist", "album"):
            kind = {"acquire": "track", "playlist": "playlist", "album": "album"}[args.command]
            return acquire(cfg, args.url, kind)
        return {"verify": verify, "audit": audit, "recover": recover, "status": status}[
            args.command
        ](cfg)
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
