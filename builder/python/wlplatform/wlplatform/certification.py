from __future__ import annotations

import hashlib
import json
import subprocess
import tarfile
import tempfile
from datetime import datetime, timezone
from pathlib import Path

from .controller import PlatformController
from .result import Status


class CertificationError(RuntimeError):
    pass


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as stream:
        for chunk in iter(
            lambda: stream.read(1024 * 1024),
            b"",
        ):
            digest.update(chunk)

    return digest.hexdigest()


def _git_value(root: Path, *args: str) -> str:
    completed = subprocess.run(
        ["git", *args],
        cwd=root,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )

    if completed.returncode != 0:
        return "unknown"

    return completed.stdout.strip()


def _write_json(path: Path, payload: object) -> None:
    path.write_text(
        json.dumps(
            payload,
            indent=2,
            sort_keys=True,
        )
        + "\n"
    )


def _source_files(root: Path) -> list[Path]:
    candidates = (
        root / "bin/wl-platform",
        root / "bin/wl-platform-status",
        root / "bin/wl-platform-certify",
        root / "builder/python/wlplatform",
    )

    files: set[Path] = set()

    for candidate in candidates:
        if candidate.is_file():
            files.add(candidate)
        elif candidate.is_dir():
            files.update(
                path
                for path in candidate.rglob("*")
                if path.is_file()
                and "__pycache__" not in path.parts
            )

    return sorted(files)


def _verify_archive(
    archive_path: Path,
    digest_path: Path,
) -> None:
    expected = digest_path.read_text().split()[0]

    if _sha256(archive_path) != expected:
        raise CertificationError(
            "Platform evidence archive checksum mismatch"
        )

    with tempfile.TemporaryDirectory(
        prefix="wl-platform-certify-"
    ) as tmp:
        destination = Path(tmp).resolve()

        with tarfile.open(
            archive_path,
            "r:gz",
        ) as archive:
            for member in archive.getmembers():
                member_path = (
                    destination / member.name
                ).resolve()

                if (
                    member_path != destination
                    and destination not in member_path.parents
                ):
                    raise CertificationError(
                        "unsafe Platform evidence archive member"
                    )

            archive.extractall(destination)

        sums = destination / "SHA256SUMS"

        if not sums.is_file():
            raise CertificationError(
                "Platform evidence archive missing SHA256SUMS"
            )

        for line in sums.read_text().splitlines():
            expected_digest, filename = line.split(
                maxsplit=1
            )
            candidate = destination / filename.strip()

            if not candidate.is_file():
                raise CertificationError(
                    f"missing evidence file: {filename}"
                )

            if _sha256(candidate) != expected_digest:
                raise CertificationError(
                    f"evidence checksum mismatch: {filename}"
                )


def certify(
    controller: PlatformController,
    *,
    include_optional: bool = False,
) -> Path:
    report = controller.verify(
        include_optional=include_optional
    )

    if report.result is Status.FAIL:
        raise CertificationError(
            "Platform verification failed"
        )

    root = controller.context.root
    created = datetime.now(timezone.utc)
    stamp = created.strftime("%Y%m%dT%H%M%SZ")

    output = (
        root
        / "vault/08-Operations/certifications/platform"
        / stamp
    )
    output.mkdir(parents=True, exist_ok=False)

    _write_json(
        output / "platform-verification.json",
        report.to_dict(),
    )

    files = _source_files(root)

    _write_json(
        output / "platform-source-manifest.json",
        {
            "schema_version": 1,
            "files": {
                str(path.relative_to(root)): {
                    "sha256": _sha256(path),
                    "size_bytes": path.stat().st_size,
                }
                for path in files
            },
        },
    )

    _write_json(
        output / "platform-certification.json",
        {
            "schema_version": 1,
            "subsystem": "platform",
            "engine_version": report.engine_version,
            "created_at": created.isoformat(),
            "result": report.result.value,
            "include_optional": include_optional,
            "repository": {
                "root": str(root),
                "branch": _git_value(
                    root,
                    "branch",
                    "--show-current",
                ),
                "commit": _git_value(
                    root,
                    "rev-parse",
                    "HEAD",
                ),
                "dirty": bool(
                    _git_value(
                        root,
                        "status",
                        "--porcelain",
                    )
                ),
            },
        },
    )

    evidence_files = sorted(
        path
        for path in output.iterdir()
        if path.is_file()
        and path.name != "SHA256SUMS"
    )

    sums = output / "SHA256SUMS"
    sums.write_text(
        "".join(
            f"{_sha256(path)}  {path.name}\n"
            for path in evidence_files
        )
    )

    archive = output / (
        f"platform-engine-1.0-evidence-{stamp}.tar.gz"
    )

    with tarfile.open(archive, "w:gz") as tar:
        for path in sorted(output.iterdir()):
            if path == archive:
                continue

            tar.add(path, arcname=path.name)

    archive_digest = output / f"{archive.name}.sha256"
    archive_digest.write_text(
        f"{_sha256(archive)}  {archive.name}\n"
    )

    _verify_archive(
        archive,
        archive_digest,
    )

    return output
