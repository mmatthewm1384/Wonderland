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
from urllib.parse import parse_qs, urlparse

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


def event(cfg: dict, event_type: str, **fields) -> None:
    record = {"timestamp": utc_now(), "event": event_type, **fields}
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


def validate_track_url(url: str) -> None:
    parsed = urlparse(url)
    host = (parsed.hostname or "").lower()
    path = parsed.path.rstrip("/")

    allowed_hosts = {
        "youtube.com",
        "www.youtube.com",
        "m.youtube.com",
        "music.youtube.com",
        "youtu.be",
    }
    if parsed.scheme not in ("http", "https") or host not in allowed_hosts:
        raise ValueError("A direct YouTube video URL is required")

    video_id = None
    if host == "youtu.be":
        video_id = path.lstrip("/").split("/")[0]
    elif path == "/watch":
        values = parse_qs(parsed.query).get("v", [])
        if len(values) == 1:
            video_id = values[0]
    else:
        match = re.fullmatch(r"/(?:shorts|live|embed)/([^/]+)", path)
        if match:
            video_id = match.group(1)

    if not video_id or not re.fullmatch(r"[A-Za-z0-9_-]{11}", video_id):
        raise ValueError(
            "Channel, artist, playlist, and catalog URLs are not valid "
            "track URLs. Supply an individual video URL."
        )


AUDIO_EXTENSIONS = {
    ".m4a",
    ".mp3",
    ".webm",
    ".opus",
    ".ogg",
    ".flac",
    ".wav",
    ".mka",
}


def media_candidates(work: Path, allowed_extensions: set[str] = AUDIO_EXTENSIONS) -> list[Path]:
    allowed = {extension.lower() for extension in allowed_extensions}
    return sorted(p for p in work.iterdir() if p.is_file() and p.suffix.lower() in allowed)


def tool_path(name: str) -> str:
    found = shutil.which(name)
    if not found:
        raise RuntimeError(f"Required executable not found on PATH: {name}")
    return found


def probe(path: Path, require_m4a: bool = False) -> dict:
    if require_m4a and path.suffix.lower() != ".m4a":
        raise RuntimeError("M4A acquisition required; non-M4A file rejected")
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
    video = [
        s
        for s in data.get("streams", [])
        if s.get("codec_type") == "video" and not s.get("disposition", {}).get("attached_pic", 0)
    ]
    if video:
        raise RuntimeError("Video stream found; audio-only media required")
    fmt = data.get("format", {})
    format_name = str(fmt.get("format_name") or "").lower().split(",")
    if require_m4a and "m4a" not in format_name:
        raise RuntimeError(f"Expected M4A container; ffprobe reported {fmt.get('format_name')!r}")
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
        "--write-thumbnail",
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


def extract_video_id(url: str) -> str:
    validate_track_url(url)
    parsed = urlparse(url)
    if parsed.hostname == "youtu.be":
        video_id = parsed.path.strip("/").split("/")[0]
    else:
        video_id = parse_qs(parsed.query).get("v", [""])[0]
        if not video_id:
            match = re.fullmatch(r"/(?:shorts|live|embed)/([^/]+)", parsed.path.rstrip("/"))
            video_id = match.group(1) if match else ""
    if not re.fullmatch(r"[A-Za-z0-9_-]{11}", video_id):
        raise ValueError("Could not extract a valid YouTube video ID")
    return video_id


def normalize_identity(value: str) -> str:
    import unicodedata

    value = unicodedata.normalize("NFKC", str(value)).casefold()
    return "".join(char for char in value if char.isalnum())


def _title_contains_sequence(actual: str, expected: str) -> bool:
    import re
    import unicodedata

    def tokens(value):
        value = unicodedata.normalize("NFKC", str(value)).casefold()
        return re.findall(r"[^\W_]+", value, flags=re.UNICODE)

    actual_tokens = tokens(actual)
    expected_tokens = tokens(expected)
    if not expected_tokens:
        return False

    width = len(expected_tokens)
    return any(
        actual_tokens[index : index + width] == expected_tokens
        for index in range(len(actual_tokens) - width + 1)
    )


def verify_track_metadata(
    media_path: Path, video_id: str, expected_identity: dict | None = None
) -> dict:
    sidecar = media_path.with_suffix(".info.json")
    if not sidecar.is_file():
        raise RuntimeError(f"Required metadata sidecar missing: {sidecar}")
    try:
        info = json.loads(sidecar.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"Cannot read metadata sidecar: {exc}") from exc

    if info.get("id") != video_id:
        raise RuntimeError(f"Source identity mismatch: expected {video_id}, got {info.get('id')!r}")

    if expected_identity is not None:
        expected_title = expected_identity.get("title")
        expected_uploader = expected_identity.get("expected_uploader")
        if not expected_title or not expected_uploader:
            raise RuntimeError("Approved identity requires title and expected_uploader")
        if not _title_contains_sequence(info.get("title", ""), expected_title):
            raise RuntimeError(
                f"Title identity mismatch: expected {expected_title!r}, got {info.get('title')!r}"
            )
        expected = normalize_identity(expected_uploader)
        actual = (info.get("uploader", ""), info.get("channel", ""))
        if not any(normalize_identity(value) == expected for value in actual if value):
            raise RuntimeError(
                f"Uploader identity mismatch: expected {expected_uploader!r}; "
                f"uploader={info.get('uploader')!r}, "
                f"channel={info.get('channel')!r}"
            )
    return info


def _safe_skin_bones_retry(manifest: dict, video_id: str) -> bool:
    if (
        video_id != "PrlvpqvqK2c"
        or manifest.get("job_id") != "20261104T142122-91b49519"
        or manifest.get("state") != "failed"
        or manifest.get("yt_dlp_started") is not False
        or manifest.get("artifacts") != []
    ):
        return False
    staging = manifest.get("staging_directory")
    if not staging:
        return False
    path = Path(staging)
    return path.is_dir() and not any(path.iterdir())


def check_source_duplicates(cfg: dict, video_id: str) -> None:
    pattern = re.compile(rf"(?<![A-Za-z0-9_-]){re.escape(video_id)}(?![A-Za-z0-9_-])")

    for key in ("incoming_dir", "staging_dir", "quarantine_dir"):
        root = cfg[key]
        if not root.is_dir():
            continue
        for path in root.rglob("*"):
            # The active source lock itself contains the video ID.
            if ".locks" in path.parts or not path.is_file():
                continue
            if pattern.search(path.name):
                raise RuntimeError(f"Source already exists in {key}: {path}")
            if path.name.endswith(".info.json"):
                try:
                    info = json.loads(path.read_text(encoding="utf-8"))
                except (OSError, UnicodeError, json.JSONDecodeError):
                    continue
                if info.get("id") == video_id:
                    raise RuntimeError(f"Source metadata already exists in {key}: {path}")

    manifests = cfg["manifest_dir"]
    if manifests.is_dir():
        for path in manifests.glob("*.json"):
            try:
                item = json.loads(path.read_text(encoding="utf-8"))
            except (OSError, UnicodeError, json.JSONDecodeError):
                continue
            if item.get("schema") != "wonderland.ytmusic.job.v1":
                continue

            matched = False
            try:
                matched = extract_video_id(item.get("source_url", "")) == video_id
            except (ValueError, TypeError, AttributeError):
                pass

            if not matched:
                matched = any(
                    isinstance(artifact, dict) and pattern.search(str(artifact.get("path", "")))
                    for artifact in item.get("artifacts", [])
                )

            if not matched:
                continue
            if _safe_skin_bones_retry(item, video_id):
                continue
            raise RuntimeError(
                f"Source already represented by historical job {path} (state={item.get('state')!r})"
            )


def acquire(cfg: dict, url: str, kind: str, expected_identity: dict | None = None) -> int:
    if kind != "track":
        return _acquire_unlocked(cfg, url, kind)

    video_id = extract_video_id(url)
    ensure_layout(cfg)
    lock_dir = cfg["staging_dir"] / ".locks"
    lock_dir.mkdir(parents=True, exist_ok=True)
    lock_path = lock_dir / f"{video_id}.lock"

    import fcntl

    with lock_path.open("a+") as lock_file:
        try:
            fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as exc:
            raise RuntimeError(f"Another acquisition holds the lock for {video_id}") from exc
        try:
            check_source_duplicates(cfg, video_id)
            return _acquire_unlocked(cfg, url, kind, expected_identity=expected_identity)
        finally:
            fcntl.flock(lock_file.fileno(), fcntl.LOCK_UN)


def _acquire_unlocked(cfg: dict, url: str, kind: str, expected_identity: dict | None = None) -> int:
    if kind == "track":
        validate_track_url(url)
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
        manifest["yt_dlp_started"] = True
        write_json_atomic(manifest_path, manifest)
        proc = subprocess.run(cmd, check=False, text=True)
        if proc.returncode != 0:
            manifest.update(state="failed", finished_at=utc_now(), exit_code=proc.returncode)
            write_json_atomic(manifest_path, manifest)
            event(cfg, "acquisition_failed", job_id=job_id, exit_code=proc.returncode)
            print(
                f"FAIL: yt-dlp exited {proc.returncode}; staging retained: {work}", file=sys.stderr
            )
            return proc.returncode

        candidates = media_candidates(work, {".m4a"})
        if not candidates:
            raise RuntimeError("yt-dlp completed but no completed audio files were found")

        promoted = []
        for src in candidates:
            if kind == "track":
                verify_track_metadata(src, extract_video_id(url), expected_identity)
            metadata = probe(src, require_m4a=True)
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
                manifest["artifacts"] = promoted
                write_json_atomic(manifest_path, manifest)
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
            manifest["artifacts"] = promoted
            write_json_atomic(manifest_path, manifest)

        manifest.update(state="completed", finished_at=utc_now(), artifacts=promoted)
        write_json_atomic(manifest_path, manifest)
        event(cfg, "acquisition_completed", job_id=job_id, artifact_count=len(promoted))
        print(f"PASS: job {job_id}; {len(promoted)} artifact(s) processed")
        return 0
    except KeyboardInterrupt:
        manifest.update(
            state="interrupted",
            finished_at=utc_now(),
            error="Interrupted by user",
        )
        write_json_atomic(manifest_path, manifest)
        event(
            cfg,
            "acquisition_interrupted",
            job_id=job_id,
            artifact_count=len(manifest.get("artifacts", [])),
        )
        print(
            f"INTERRUPTED: job {job_id}; staging retained: {work}",
            file=sys.stderr,
        )
        return 130
    except Exception as exc:
        manifest.update(state="verification_failed", finished_at=utc_now(), error=str(exc))
        write_json_atomic(manifest_path, manifest)
        event(cfg, "acquisition_verification_failed", job_id=job_id, error=str(exc))
        print(f"FAIL: {exc}; staging retained: {work}", file=sys.stderr)
        return 1


APPROVED_BATCH_SHA256 = "d497d2eaf5a463b4d2fcfe9561f3a2f3a31cafc110fd81adc3c6749e0570f0e7"


def validate_batch_document(document: dict, cfg: dict) -> list[dict]:
    if document.get("schema") != "wonderland.ytmusic.batch.v1":
        raise RuntimeError("Unsupported batch manifest schema")
    if document.get("batch_id") != "20261105-001":
        raise RuntimeError("Unexpected batch ID")
    if document.get("state") != "approved":
        raise RuntimeError("Batch is not approved")

    approval = document.get("approval")
    if not isinstance(approval, dict):
        raise RuntimeError("Missing approval record")

    if approval.get("identity_approval") is not True:
        raise RuntimeError("Identity approval is not true")
    if approval.get("format") != "m4a" or approval.get("transcoding") is not False:
        raise RuntimeError("Batch format policy mismatch")
    if cfg.get("format") != "bestaudio[ext=m4a]":
        raise RuntimeError("Configured acquisition format is not canonical M4A")
    if cfg.get("audio_quality_policy") != "preserve_source":
        raise RuntimeError("Configured audio quality policy mismatch")

    tracks = document.get("tracks")
    if not isinstance(tracks, list):
        raise RuntimeError("Batch tracks must be a list")

    count = approval.get("approved_track_count")
    maximum = approval.get("maximum_batch_size")
    if not isinstance(count, int) or isinstance(count, bool):
        raise RuntimeError("Invalid approved track count")
    if not isinstance(maximum, int) or isinstance(maximum, bool):
        raise RuntimeError("Invalid maximum batch size")
    if maximum < 1 or maximum > 10:
        raise RuntimeError("Batch maximum exceeds the controlled limit of 10")
    if count != len(tracks) or count > maximum:
        raise RuntimeError("Approved track count does not match manifest")

    seen_ids = set()
    seen_positions = set()
    excluded_ids = {
        item.get("video_id")
        for item in document.get("excluded", [])
        if isinstance(item, dict) and item.get("video_id")
    }

    for track in tracks:
        if not isinstance(track, dict):
            raise RuntimeError("Invalid track record")
        video_id = track.get("video_id")
        title = track.get("title")
        uploader = track.get("expected_uploader")
        position = track.get("position")

        if not isinstance(video_id, str) or not re.fullmatch(r"[A-Za-z0-9_-]{11}", video_id):
            raise RuntimeError("Invalid approved video ID")
        if not isinstance(title, str) or not title.strip():
            raise RuntimeError(f"Missing title for {video_id}")
        if not isinstance(uploader, str) or not uploader.strip():
            raise RuntimeError(f"Missing expected uploader for {video_id}")
        if track.get("identity_status") != "approved":
            raise RuntimeError(f"Track identity is not approved: {video_id}")
        if not isinstance(position, int) or isinstance(position, bool):
            raise RuntimeError(f"Invalid position for {video_id}")
        if video_id in seen_ids or position in seen_positions:
            raise RuntimeError("Duplicate video ID or track position")
        if video_id in excluded_ids:
            raise RuntimeError(f"Excluded video ID appears in approved tracks: {video_id}")

        seen_ids.add(video_id)
        seen_positions.add(position)

    if seen_positions != set(range(1, count + 1)):
        raise RuntimeError("Track positions must be contiguous from 1")

    return sorted(tracks, key=lambda item: item["position"])


def _batch_manifest_path(cfg: dict, manifest_path) -> Path:
    path = Path(manifest_path)
    if not path.is_absolute():
        path = APP_ROOT / path
    return path


def _batch_load_approved(cfg: dict, manifest_path):
    path = _batch_manifest_path(cfg, manifest_path)
    if not path.is_file():
        raise RuntimeError(f"Batch manifest not found: {path}")
    actual = sha256(path)
    if actual != APPROVED_BATCH_SHA256:
        raise RuntimeError(f"Approved manifest checksum mismatch: {actual}")
    document = json.loads(path.read_text(encoding="utf-8"))
    tracks = validate_batch_document(document, cfg)
    return path, document, tracks


def _batch_matching_jobs(cfg: dict, video_id: str) -> list[dict]:
    matches = []
    for path in cfg["manifest_dir"].glob("*.json"):
        try:
            item = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, UnicodeError, json.JSONDecodeError):
            continue
        if item.get("schema") != "wonderland.ytmusic.job.v1":
            continue
        try:
            matched = extract_video_id(item.get("source_url", "")) == video_id
        except (ValueError, TypeError, AttributeError):
            matched = False
        if matched and not _safe_skin_bones_retry(item, video_id):
            matches.append({"path": path, "manifest": item})
    return matches


def _batch_verify_artifact(artifact: dict, track: dict) -> dict:
    if not isinstance(artifact, dict):
        raise RuntimeError("Artifact record is missing or invalid")
    path_value = artifact.get("path")
    expected_hash = artifact.get("sha256")
    if not path_value or not expected_hash:
        raise RuntimeError("Artifact record lacks path or SHA-256")
    path = Path(path_value)
    if not path.is_file() or path.suffix.lower() != ".m4a":
        raise RuntimeError(f"Completed artifact is missing or not M4A: {path}")
    actual_hash = sha256(path)
    if actual_hash != expected_hash:
        raise RuntimeError(f"Artifact checksum mismatch: {path}")
    metadata = verify_track_metadata(
        path,
        track["video_id"],
        {
            "title": track["title"],
            "expected_uploader": track["expected_uploader"],
        },
    )
    return {
        "path": str(path),
        "sha256": actual_hash,
        "video_id": track["video_id"],
        "metadata_title": metadata.get("title"),
        "metadata_uploader": metadata.get("uploader"),
    }


def _batch_reconcile_job(cfg: dict, track: dict):
    jobs = _batch_matching_jobs(cfg, track["video_id"])
    if not jobs:
        return None
    if len(jobs) != 1:
        raise RuntimeError(f"Ambiguous history: {len(jobs)} jobs match {track['video_id']}")

    job = jobs[0]["manifest"]
    if job.get("state") != "completed":
        raise RuntimeError(
            f"Historical job for {track['video_id']} is not completed "
            f"(state={job.get('state')!r}); manual review required"
        )
    artifacts = job.get("artifacts")
    if not isinstance(artifacts, list) or len(artifacts) != 1:
        raise RuntimeError("Completed track job must contain exactly one artifact")

    verified = _batch_verify_artifact(artifacts[0], track)
    return {
        "job_id": job.get("job_id"),
        "artifact": verified,
        "reconciled": True,
    }


def _batch_verify_recovery_evidence(
    cfg: dict, record: dict, track: dict, verified_artifact: dict
) -> dict | None:
    if record.get("recovered") is not True:
        return None

    recovery_root = (cfg["manifest_dir"] / "recoveries").resolve()
    evidence_value = record.get("recovery_evidence")
    expected_digest = record.get("recovery_evidence_sha256")
    if not evidence_value or not expected_digest:
        raise RuntimeError("Recovered report record lacks recovery evidence")

    evidence_path = Path(evidence_value)
    if evidence_path.is_symlink():
        raise RuntimeError("Recovery evidence path must not be a symlink")
    resolved = evidence_path.resolve(strict=True)
    if resolved.parent != recovery_root:
        raise RuntimeError("Recovery evidence is outside the recovery directory")
    if sha256(resolved) != expected_digest:
        raise RuntimeError("Recovery evidence checksum mismatch")

    with resolved.open("r", encoding="utf-8") as stream:
        evidence = json.load(stream)

    if evidence.get("schema") != "wonderland.ytmusic.recovery.v1":
        raise RuntimeError("Invalid recovery evidence schema")
    if evidence.get("batch_id") != "20261105-001":
        raise RuntimeError("Recovery evidence batch ID mismatch")
    if evidence.get("source_manifest_sha256") != APPROVED_BATCH_SHA256:
        raise RuntimeError("Recovery evidence source manifest mismatch")
    if evidence.get("video_id") != record.get("video_id"):
        raise RuntimeError("Recovery evidence video ID mismatch")
    if evidence.get("job_id") != record.get("job_id"):
        raise RuntimeError("Recovery evidence job ID mismatch")

    staged = evidence.get("staged_artifact") or {}
    staged_path = Path(staged.get("path", ""))
    if staged_path.is_symlink() or not staged_path.is_file():
        raise RuntimeError("Recovered staging artifact is missing or unsafe")
    if sha256(staged_path) != staged.get("sha256"):
        raise RuntimeError("Recovered staging artifact checksum mismatch")

    promoted = evidence.get("promoted_artifact") or {}
    if promoted.get("sha256") != verified_artifact.get("sha256"):
        raise RuntimeError("Recovery evidence artifact digest mismatch")
    if (
        Path(promoted.get("path", "")).resolve()
        != Path(verified_artifact.get("path", "")).resolve()
    ):
        raise RuntimeError("Recovery evidence artifact path mismatch")

    return evidence


def _batch_verify_report_record(cfg: dict, record: dict, track: dict) -> dict:
    if record.get("state") != "completed":
        raise RuntimeError("Report record is not completed")
    verified = _batch_verify_artifact(record.get("artifact"), track)
    recovery = _batch_verify_recovery_evidence(cfg, record, track, verified)
    return {
        "job_id": record.get("job_id"),
        "artifact": verified,
        "reconciled": False,
        "recovered": recovery is not None,
    }


def run_approved_batch(cfg: dict, manifest_path, dry_run: bool = False) -> int:
    try:
        path, document, tracks = _batch_load_approved(cfg, manifest_path)
        report_dir = cfg["manifest_dir"] / "batch-runs"
        report_path = report_dir / f"{document['batch_id']}.json"

        if report_path.exists():
            report = json.loads(report_path.read_text(encoding="utf-8"))
            if (
                report.get("schema") != "wonderland.ytmusic.batch-run.v1"
                or report.get("batch_id") != document["batch_id"]
                or report.get("source_manifest_sha256") != APPROVED_BATCH_SHA256
            ):
                raise RuntimeError("Existing batch report does not match approval")
            records = report.get("tracks")
            if not isinstance(records, dict):
                raise RuntimeError("Existing batch report has invalid track records")
        else:
            report = {
                "schema": "wonderland.ytmusic.batch-run.v1",
                "batch_id": document["batch_id"],
                "source_manifest": str(path),
                "source_manifest_sha256": APPROVED_BATCH_SHA256,
                "state": "preflight" if dry_run else "running",
                "started_at": utc_now(),
                "tracks": {},
            }
            records = report["tracks"]

        for track in tracks:
            video_id = track["video_id"]
            previous = records.get(video_id)

            if previous and previous.get("state") == "completed":
                _batch_verify_report_record(cfg, previous, track)
                print(f"PASS: {track['position']} {track['title']} — verified report artifact")
                continue

            if previous and previous.get("state") in ("running", "failed"):
                reconciled = _batch_reconcile_job(cfg, track)
                if reconciled is None:
                    raise RuntimeError(
                        f"Track {video_id} has prior {previous['state']} state "
                        "without a verifiable completed job; manual review required"
                    )
                records[video_id] = {
                    "position": track["position"],
                    "title": track["title"],
                    "state": "completed",
                    **reconciled,
                }
                if not dry_run:
                    report.update(state="running", updated_at=utc_now())
                    write_json_atomic(report_path, report)
                print(f"PASS: {track['position']} {track['title']} — reconciled job")
                continue

            reconciled = _batch_reconcile_job(cfg, track)
            if reconciled is not None:
                records[video_id] = {
                    "position": track["position"],
                    "title": track["title"],
                    "state": "completed",
                    **reconciled,
                }
                if not dry_run:
                    report.update(state="running", updated_at=utc_now())
                    write_json_atomic(report_path, report)
                print(f"PASS: {track['position']} {track['title']} — recovered completed job")
                continue

            check_source_duplicates(cfg, video_id)
            if dry_run:
                print(f"READY: {track['position']} {track['title']} [{video_id}]")
                continue

            records[video_id] = {
                "position": track["position"],
                "title": track["title"],
                "state": "running",
                "started_at": utc_now(),
            }
            report.update(state="running", updated_at=utc_now())
            report_dir.mkdir(parents=True, exist_ok=True)
            write_json_atomic(report_path, report)

            url = f"https://www.youtube.com/watch?v={video_id}"
            result = acquire(
                cfg,
                url,
                "track",
                expected_identity={
                    "title": track["title"],
                    "expected_uploader": track["expected_uploader"],
                },
            )
            if result != 0:
                records[video_id].update(
                    state="failed",
                    exit_code=result,
                    finished_at=utc_now(),
                )
                report.update(state="failed", updated_at=utc_now())
                write_json_atomic(report_path, report)
                print(f"FAIL: {track['title']} returned exit code {result}", file=sys.stderr)
                return result

            reconciled = _batch_reconcile_job(cfg, track)
            if reconciled is None:
                raise RuntimeError(
                    f"Acquisition returned success but no completed job can be verified: {video_id}"
                )
            records[video_id].update(
                state="completed",
                finished_at=utc_now(),
                **reconciled,
            )
            report.update(state="running", updated_at=utc_now())
            write_json_atomic(report_path, report)
            print(f"PASS: {track['position']} {track['title']} — acquired and verified")

        if dry_run:
            print(f"PASS: preflight complete; {len(tracks)} approved tracks checked")
            return 0

        report.update(
            state="completed",
            finished_at=utc_now(),
            completed_track_count=len(tracks),
        )
        write_json_atomic(report_path, report)
        print(f"PASS: batch {document['batch_id']} completed; {len(tracks)} tracks")
        print(f"REPORT: {report_path}")
        return 0

    except Exception as exc:
        print(f"FAIL: batch stopped safely: {exc}", file=sys.stderr)
        return 2


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
    batch_parser = sub.add_parser("batch")
    batch_parser.add_argument(
        "manifest",
        nargs="?",
        default="manifests/batch-20261105-001.json",
    )
    batch_parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)
    try:
        cfg = load_config()
        if args.command in ("acquire", "playlist", "album"):
            kind = {"acquire": "track", "playlist": "playlist", "album": "album"}[args.command]
            return acquire(cfg, args.url, kind)
        if args.command == "batch":
            return run_approved_batch(cfg, args.manifest, dry_run=args.dry_run)
        return {"verify": verify, "audit": audit, "recover": recover, "status": status}[
            args.command
        ](cfg)
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
