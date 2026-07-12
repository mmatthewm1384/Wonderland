from __future__ import annotations

import hashlib
import json
import subprocess
import tarfile
import tempfile
from datetime import datetime, timezone
from pathlib import Path

from .context import AcademyContext
from .result import Status
from .verifier import verify
from .version import __version__


class CertificationError(RuntimeError):
    pass


def sha256(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as stream:
        for chunk in iter(
            lambda: stream.read(1024 * 1024),
            b"",
        ):
            digest.update(chunk)

    return digest.hexdigest()


def git_value(
    root: Path,
    *args: str,
) -> str:
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


def write_json(
    path: Path,
    payload: object,
) -> None:
    path.write_text(
        json.dumps(
            payload,
            indent=2,
            sort_keys=True,
        )
        + "\n"
    )


def source_files(
    context: AcademyContext,
) -> list[Path]:
    candidates = (
        context.root / "bin/wl-academy",
        context.root / "bin/wl-academy-verify",
        context.root / "bin/wl-academy-certify",
        context.root / "bin/wl-academy-legacy",
        context.root / "builder/python/wlacademy",
        context.root / "academy",
        context.root / "lib/academy",
        context.root / "vault/05-Registry/academy",
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


def verify_archive(
    archive: Path,
    digest_path: Path,
) -> None:
    expected = digest_path.read_text().split()[0]

    if sha256(archive) != expected:
        raise CertificationError(
            "Academy evidence archive checksum mismatch"
        )

    with tempfile.TemporaryDirectory(
        prefix="wl-academy-certify-"
    ) as tmp:
        destination = Path(tmp).resolve()

        with tarfile.open(archive, "r:gz") as tar:
            for member in tar.getmembers():
                member_path = (
                    destination / member.name
                ).resolve()

                if (
                    member_path != destination
                    and destination not in member_path.parents
                ):
                    raise CertificationError(
                        "unsafe Academy evidence archive member"
                    )

            tar.extractall(destination)

        sums = destination / "SHA256SUMS"

        if not sums.is_file():
            raise CertificationError(
                "Academy archive missing SHA256SUMS"
            )

        for line in sums.read_text().splitlines():
            expected_digest, filename = line.split(
                maxsplit=1
            )
            candidate = destination / filename.strip()

            if not candidate.is_file():
                raise CertificationError(
                    f"missing Academy evidence file: {filename}"
                )

            if sha256(candidate) != expected_digest:
                raise CertificationError(
                    f"Academy evidence checksum mismatch: "
                    f"{filename}"
                )


def certify(context: AcademyContext) -> Path:
    results, overall, duration_ms = verify(context)

    if overall is Status.FAIL:
        raise CertificationError(
            "Academy verification failed"
        )

    created = datetime.now(timezone.utc)
    stamp = created.strftime("%Y%m%dT%H%M%SZ")
    output = context.certification_root / stamp
    output.mkdir(parents=True, exist_ok=False)

    write_json(
        output / "academy-verification.json",
        {
            "schema_version": 1,
            "engine_version": __version__,
            "root": str(context.root),
            "result": overall.value,
            "duration_ms": duration_ms,
            "checks": [
                result.to_dict()
                for result in results
            ],
        },
    )

    write_json(
        output / "academy-source-manifest.json",
        {
            "schema_version": 1,
            "files": {
                str(path.relative_to(context.root)): {
                    "sha256": sha256(path),
                    "size_bytes": path.stat().st_size,
                }
                for path in source_files(context)
            },
        },
    )

    write_json(
        output / "academy-certification.json",
        {
            "schema_version": 1,
            "subsystem": "academy",
            "engine_version": __version__,
            "created_at": created.isoformat(),
            "result": overall.value,
            "repository": {
                "root": str(context.root),
                "branch": git_value(
                    context.root,
                    "branch",
                    "--show-current",
                ),
                "commit": git_value(
                    context.root,
                    "rev-parse",
                    "HEAD",
                ),
                "dirty": bool(
                    git_value(
                        context.root,
                        "status",
                        "--porcelain",
                    )
                ),
            },
        },
    )

    evidence = sorted(
        path
        for path in output.iterdir()
        if path.is_file()
        and path.name != "SHA256SUMS"
    )

    sums = output / "SHA256SUMS"
    sums.write_text(
        "".join(
            f"{sha256(path)}  {path.name}\n"
            for path in evidence
        )
    )

    archive = output / (
        f"academy-engine-1.0-evidence-{stamp}.tar.gz"
    )

    with tarfile.open(archive, "w:gz") as tar:
        for path in sorted(output.iterdir()):
            if path == archive:
                continue

            tar.add(path, arcname=path.name)

    digest_path = output / f"{archive.name}.sha256"
    digest_path.write_text(
        f"{sha256(archive)}  {archive.name}\n"
    )

    verify_archive(archive, digest_path)

    return output
