#!/usr/bin/env python3
"""Explicit, evidence-preserving recovery of the approved SEROTONIN acquisition."""

from __future__ import annotations

import fcntl
import hashlib
import importlib.util
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VIDEO_ID = "MtAsU2cGKxs"
BATCH_ID = "20261105-001"
JOB_ID = "20261105T141822-9132899e"
EXPECTED_SOURCE_SHA256 = "d497d2eaf5a463b4d2fcfe9561f3a2f3a31cafc110fd81adc3c6749e0570f0e7"
EXPECTED_JOB_SHA256 = "15009d363e47dfe0e194704661c542178fd75a38e8178577613a4b2f12b92947"
EXPECTED_MEDIA_SHA256 = "09d56686db963cf7cdab74d19a6b5c41a4c86d791f380465a7cfd94fe7027f10"
EXPECTED_TITLE = "SEROTONIN"
EXPECTED_UPLOADER = "LaLion"
SCHEMA = "wonderland.ytmusic.recovery.v1"

spec = importlib.util.spec_from_file_location(
    "wonderland_ytmusic_recovery_target", ROOT / "lib" / "ytmusic.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Cannot load YTMusic implementation")
ytmusic = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = ytmusic
spec.loader.exec_module(ytmusic)


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def inside(path: Path, parent: Path) -> bool:
    try:
        path.resolve(strict=True).relative_to(parent.resolve(strict=True))
        return True
    except (ValueError, FileNotFoundError):
        return False


def read_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as stream:
        value = json.load(stream)
    if not isinstance(value, dict):
        raise RuntimeError(f"Expected JSON object: {path}")
    return value


def sidecar_for(media: Path) -> Path:
    candidates = [
        media.with_suffix(".info.json"),
        Path(str(media) + ".info.json"),
    ]
    found = [p for p in candidates if p.is_file() and not p.is_symlink()]
    if len(found) != 1:
        raise RuntimeError("Expected exactly one regular .info.json sidecar")
    return found[0]


def ensure_sidecar(media: Path, source_sidecar: Path) -> Path:
    destination = media.with_suffix(".info.json")
    if destination.is_symlink():
        raise RuntimeError("Destination metadata sidecar must not be a symlink")
    if destination.exists():
        if not destination.is_file() or sha(destination) != sha(source_sidecar):
            raise RuntimeError("Conflicting destination metadata sidecar")
    else:
        try:
            os.link(source_sidecar, destination)
        except FileExistsError:
            if destination.is_symlink() or not destination.is_file():
                raise RuntimeError("Unsafe destination metadata sidecar")
            if sha(destination) != sha(source_sidecar):
                raise RuntimeError("Conflicting destination metadata sidecar")
    return destination


def verify_identity(media: Path, sidecar: Path) -> dict:
    info = read_json(sidecar)
    if info.get("id") != VIDEO_ID:
        raise RuntimeError("Staged metadata video ID mismatch")
    if not ytmusic._title_contains_sequence(str(info.get("title", "")), EXPECTED_TITLE):
        raise RuntimeError("Staged metadata title mismatch")
    uploader = info.get("uploader") or info.get("channel") or ""
    if ytmusic.normalize_identity(uploader) != ytmusic.normalize_identity(EXPECTED_UPLOADER):
        raise RuntimeError("Staged metadata uploader mismatch")
    return {
        "video_id": info.get("id"),
        "title": info.get("title"),
        "uploader": uploader,
    }


def verify_evidence(
    evidence: dict,
    staged: Path,
    promoted: Path,
    source_manifest: Path,
    job_path: Path,
) -> None:
    def exact_path(value: str, expected_path: Path, label: str) -> Path:
        candidate = Path(value)
        if candidate.is_symlink() or not candidate.is_file():
            raise RuntimeError(f"{label} must be a regular non-symlink file")
        resolved = candidate.resolve(strict=True)
        if resolved != expected_path.resolve(strict=True):
            raise RuntimeError(f"{label} path mismatch")
        return resolved

    if evidence.get("schema") != SCHEMA:
        raise RuntimeError("Existing recovery evidence has an invalid schema")
    if evidence.get("batch_id") != BATCH_ID or evidence.get("video_id") != VIDEO_ID:
        raise RuntimeError("Existing recovery evidence identity mismatch")
    if evidence.get("job_id") != JOB_ID:
        raise RuntimeError("Existing recovery evidence job mismatch")

    source = exact_path(evidence.get("source_manifest", ""), source_manifest, "Source manifest")
    if evidence.get("source_manifest_sha256") != EXPECTED_SOURCE_SHA256:
        raise RuntimeError("Evidence source manifest digest declaration mismatch")
    if sha(source) != EXPECTED_SOURCE_SHA256:
        raise RuntimeError("Approved source manifest checksum mismatch")

    job_file = exact_path(evidence.get("job_manifest", ""), job_path, "Original job manifest")
    if evidence.get("job_manifest_sha256") != EXPECTED_JOB_SHA256:
        raise RuntimeError("Evidence job manifest digest declaration mismatch")
    if sha(job_file) != EXPECTED_JOB_SHA256:
        raise RuntimeError("Original failed job checksum mismatch")

    job = read_json(job_file)
    if (
        job.get("schema") != "wonderland.ytmusic.job.v1"
        or job.get("job_id") != JOB_ID
        or job.get("kind") != "track"
        or job.get("state") != "verification_failed"
        or ytmusic.extract_video_id(job.get("source_url", "")) != VIDEO_ID
        or job.get("artifacts") != []
    ):
        raise RuntimeError("Original failed job manifest identity/state mismatch")

    a = evidence.get("staged_artifact") or {}
    b = evidence.get("promoted_artifact") or {}

    staged_file = exact_path(a.get("path", ""), staged, "Staged artifact")
    if a.get("sha256") != EXPECTED_MEDIA_SHA256 or sha(staged_file) != EXPECTED_MEDIA_SHA256:
        raise RuntimeError("Staged artifact checksum/declaration mismatch")

    promoted_file = exact_path(b.get("path", ""), promoted, "Promoted artifact")
    if b.get("sha256") != EXPECTED_MEDIA_SHA256 or sha(promoted_file) != EXPECTED_MEDIA_SHA256:
        raise RuntimeError("Promoted artifact checksum/declaration mismatch")

    sidecar = Path(a.get("sidecar", ""))
    if sidecar.is_symlink() or not sidecar.is_file():
        raise RuntimeError("Staged metadata sidecar is missing or unsafe")
    verify_identity(staged_file, sidecar)

    promoted_sidecar = promoted_file.with_suffix(".info.json")
    if promoted_sidecar.is_symlink() or not promoted_sidecar.is_file():
        raise RuntimeError("Promoted metadata sidecar is missing or unsafe")
    verify_identity(promoted_file, promoted_sidecar)


def verify_existing_evidence_file(
    evidence_path: Path,
    staged: Path,
    promoted: Path,
    source_manifest: Path,
    job_path: Path,
) -> dict:
    if evidence_path.is_symlink():
        raise RuntimeError("Recovery evidence path must not be a symlink")
    if not evidence_path.is_file():
        raise RuntimeError("Recovery evidence must be a regular file")

    evidence = read_json(evidence_path)
    verify_evidence(evidence, staged, promoted, source_manifest, job_path)
    return evidence


def recover() -> None:
    cfg = ytmusic.load_config()
    manifest_dir = cfg["manifest_dir"]
    staging_root = cfg["staging_dir"].resolve()
    incoming = cfg["incoming_dir"].resolve()

    source_manifest = manifest_dir / f"batch-{BATCH_ID}.json"
    if sha(source_manifest) != EXPECTED_SOURCE_SHA256:
        raise RuntimeError("Approved batch manifest checksum mismatch")
    batch = read_json(source_manifest)
    ytmusic.validate_batch_document(batch, cfg)

    # Find the approved source entry by its exact video ID.
    tracks = batch.get("tracks")
    if not isinstance(tracks, list):
        raise RuntimeError("Approved batch tracks are not a list")
    matches = [
        item for item in tracks if isinstance(item, dict) and item.get("video_id") == VIDEO_ID
    ]
    if len(matches) != 1:
        raise RuntimeError("Approved manifest does not contain exactly one SEROTONIN entry")
    approved_track = matches[0]
    expected_fields = {
        "title": EXPECTED_TITLE,
        "artist": EXPECTED_UPLOADER,
        "expected_uploader": EXPECTED_UPLOADER,
        "identity_status": "approved",
    }
    for field, expected in expected_fields.items():
        if approved_track.get(field) != expected:
            raise RuntimeError(
                f"Approved manifest {field} mismatch: "
                f"expected {expected!r}, got {approved_track.get(field)!r}"
            )

    job_path = manifest_dir / f"{JOB_ID}.json"
    if sha(job_path) != EXPECTED_JOB_SHA256:
        raise RuntimeError("Original failed job manifest checksum mismatch")
    job = read_json(job_path)
    if (
        job.get("schema") != "wonderland.ytmusic.job.v1"
        or job.get("job_id") != JOB_ID
        or job.get("kind") != "track"
        or job.get("state") != "verification_failed"
        or ytmusic.extract_video_id(job.get("source_url", "")) != VIDEO_ID
    ):
        raise RuntimeError("Original failed job manifest identity/state mismatch")
    if job.get("artifacts") != []:
        raise RuntimeError("Failed job unexpectedly contains promoted artifacts")

    staging = Path(job.get("staging_directory", ""))
    if staging.is_symlink() or not inside(staging, staging_root):
        raise RuntimeError("Staging directory is outside configured staging root")
    if staging.resolve() == staging_root or not staging.is_dir():
        raise RuntimeError("Staging directory is invalid")

    lock_dir = cfg["staging_dir"] / ".locks"
    lock_dir.mkdir(parents=True, exist_ok=True)
    lock_path = lock_dir / f"{VIDEO_ID}.lock"
    with lock_path.open("a+") as lock:
        try:
            fcntl.flock(lock.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as exc:
            raise RuntimeError("SEROTONIN is locked by another acquisition/recovery") from exc

        try:
            media_candidates = [
                p
                for p in staging.iterdir()
                if p.is_file()
                and not p.is_symlink()
                and p.suffix.lower() == ".m4a"
                and f"[{VIDEO_ID}]" in p.name
            ]
            if len(media_candidates) != 1:
                raise RuntimeError("Expected exactly one staged M4A for this video ID")
            staged = media_candidates[0]
            if sha(staged) != EXPECTED_MEDIA_SHA256:
                raise RuntimeError("Staged M4A checksum mismatch")

            staged_sidecar = sidecar_for(staged)
            identity = verify_identity(staged, staged_sidecar)
            staged_probe = ytmusic.probe(staged, require_m4a=True)

            incoming.mkdir(parents=True, exist_ok=True)
            matches = []
            for candidate in incoming.iterdir():
                if candidate.is_symlink():
                    if VIDEO_ID in candidate.name:
                        raise RuntimeError("Symlink uses the approved video ID in incoming")
                    continue

                if candidate.is_file() and candidate.suffix.lower() == ".m4a":
                    if f"[{VIDEO_ID}]" in candidate.name:
                        if sha(candidate) != EXPECTED_MEDIA_SHA256:
                            raise RuntimeError(
                                "Incoming filename already uses this video ID with different content"
                            )
                    if sha(candidate) == EXPECTED_MEDIA_SHA256:
                        matches.append(candidate)

                if candidate.is_file() and candidate.name.endswith(".info.json"):
                    try:
                        incoming_info = read_json(candidate)
                    except Exception as exc:
                        raise RuntimeError(
                            f"Cannot safely inspect incoming sidecar: {candidate.name}"
                        ) from exc
                    if incoming_info.get("id") == VIDEO_ID:
                        associated = Path(str(candidate)[: -len(".info.json")] + ".m4a")
                        if not associated.is_file() or associated.is_symlink():
                            raise RuntimeError(
                                "Incoming sidecar claims this video ID but its M4A is missing"
                            )
                        if sha(associated) != EXPECTED_MEDIA_SHA256:
                            raise RuntimeError(
                                "Incoming sidecar claims this video ID for different content"
                            )
                        if associated not in matches:
                            matches.append(associated)
            if len(matches) > 1:
                raise RuntimeError("Multiple identical M4A artifacts already exist in incoming")

            if matches:
                promoted = matches[0]
                promoted_sidecar = ensure_sidecar(promoted, staged_sidecar)
                verify_identity(promoted, promoted_sidecar)
                promoted_probe = ytmusic.probe(promoted, require_m4a=True)
                result = "duplicate_noop"
            else:
                base = incoming / staged.name
                counter = 0
                while True:
                    promoted = (
                        base
                        if counter == 0
                        else base.with_name(f"{base.stem} ({counter}){base.suffix}")
                    )
                    promoted_sidecar = promoted.with_suffix(".info.json")
                    try:
                        os.link(staged, promoted)
                        break
                    except FileExistsError:
                        counter += 1

                # Sidecar creation is idempotent if a prior attempt linked the media only.
                promoted_sidecar = ensure_sidecar(promoted, staged_sidecar)
                if sha(promoted) != EXPECTED_MEDIA_SHA256:
                    raise RuntimeError("Promoted M4A checksum mismatch")
                verify_identity(promoted, promoted_sidecar)
                promoted_probe = ytmusic.probe(promoted, require_m4a=True)
                result = "promoted"

            artifact = {
                "sha256": EXPECTED_MEDIA_SHA256,
                "path": str(promoted),
                "result": result,
                "probe": promoted_probe,
            }

            recovery_dir = manifest_dir / "recoveries"
            recovery_dir.mkdir(parents=True, exist_ok=True)
            evidence_path = recovery_dir / f"{JOB_ID}.json"

            evidence = {
                "schema": SCHEMA,
                "created_at": ytmusic.utc_now(),
                "batch_id": BATCH_ID,
                "source_manifest": str(source_manifest),
                "source_manifest_sha256": EXPECTED_SOURCE_SHA256,
                "job_id": JOB_ID,
                "job_manifest": str(job_path),
                "job_manifest_sha256": EXPECTED_JOB_SHA256,
                "video_id": VIDEO_ID,
                "staging_directory": str(staging),
                "staged_artifact": {
                    "path": str(staged),
                    "sha256": EXPECTED_MEDIA_SHA256,
                    "sidecar": str(staged_sidecar),
                    "identity": identity,
                    "probe": staged_probe,
                },
                "promoted_artifact": artifact,
            }

            if evidence_path.exists() or evidence_path.is_symlink():
                evidence = verify_existing_evidence_file(
                    evidence_path, staged, promoted, source_manifest, job_path
                )
            else:
                # Exclusive creation: never overwrite recovery evidence.
                with evidence_path.open("x", encoding="utf-8") as stream:
                    json.dump(evidence, stream, indent=2, sort_keys=True)
                    stream.write("\n")
                    stream.flush()
                    os.fsync(stream.fileno())

            evidence_digest = sha(evidence_path)
            report_path = manifest_dir / "batch-runs" / f"{BATCH_ID}.json"
            report = read_json(report_path)
            if (
                report.get("schema") != "wonderland.ytmusic.batch-run.v1"
                or report.get("batch_id") != BATCH_ID
                or report.get("source_manifest_sha256") != EXPECTED_SOURCE_SHA256
            ):
                raise RuntimeError("Batch report identity/source mismatch")

            records = report.setdefault("tracks", {})
            previous = records.get(VIDEO_ID)
            if not isinstance(previous, dict):
                raise RuntimeError("Batch report has no failed SEROTONIN record")

            if previous.get("state") == "completed" and previous.get("recovered") is True:
                if (
                    previous.get("recovery_evidence_sha256") != evidence_digest
                    or Path(previous.get("recovery_evidence", "")).resolve()
                    != evidence_path.resolve()
                ):
                    raise RuntimeError("Existing recovered report record conflicts")
                print("PASS: SEROTONIN recovery already recorded and verified")
                return

            if (
                previous.get("state") != "failed"
                or previous.get("title") != EXPECTED_TITLE
                or previous.get("position") != 1
            ):
                raise RuntimeError("Batch report is not in the expected failed state")

            previous.update(
                {
                    "state": "completed",
                    "job_id": JOB_ID,
                    "video_id": VIDEO_ID,
                    "artifact": artifact,
                    "recovered": True,
                    "recovery_evidence": str(evidence_path),
                    "recovery_evidence_sha256": evidence_digest,
                    "recovered_at": ytmusic.utc_now(),
                }
            )
            report["state"] = "running"
            report["updated_at"] = ytmusic.utc_now()
            ytmusic.write_json_atomic(report_path, report)

            print("PASS: SEROTONIN recovery evidence committed")
            print(f"ARTIFACT: {promoted}")
            print(f"EVIDENCE: {evidence_path}")
            print("ORIGINAL FAILED JOB MANIFEST: unchanged")
            print("STAGING SOURCE: retained")

        finally:
            fcntl.flock(lock.fileno(), fcntl.LOCK_UN)


if __name__ == "__main__":
    try:
        recover()
    except Exception as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
