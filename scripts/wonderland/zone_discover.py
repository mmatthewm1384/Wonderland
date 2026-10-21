#!/usr/bin/env python3
"""Read-only deterministic discovery for Mattie's Room candidate manifests."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any

ENVIRONMENT_KINDS = {"physical", "virtual", "simulated", "imagined", "abstract", "hybrid", "computational"}
IDENTIFIER_RE = re.compile(r"^[a-z0-9][a-z0-9._-]{1,127}$")


def canonical_json(value: Any) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def candidate_id(path: Path, payload: dict[str, Any], root: Path) -> tuple[str, str]:
    metadata = payload.get("metadata")
    declared = metadata.get("id") if isinstance(metadata, dict) else None
    if isinstance(declared, str) and declared.strip():
        return declared.strip(), "declared"
    source = path.relative_to(root).as_posix()
    digest = hashlib.sha256((source + "\0" + canonical_json(payload)).encode("utf-8")).hexdigest()[:24]
    return "candidate-" + digest, "provisional"


def validate_environment(payload: Any) -> list[str]:
    """Validate the supported Environment v1 contract without third-party dependencies."""
    if not isinstance(payload, dict):
        return ["manifest root must be a JSON object"]
    errors: list[str] = []
    if payload.get("apiVersion") != "wonderland.dev/v1":
        errors.append("apiVersion must be wonderland.dev/v1")
    if payload.get("kind") != "Environment":
        errors.append("kind must be Environment")
    metadata = payload.get("metadata")
    if not isinstance(metadata, dict):
        errors.append("metadata must be a JSON object")
    else:
        name = metadata.get("name")
        if not isinstance(name, str) or not name.strip() or len(name) > 160:
            errors.append("metadata.name must be a non-empty string of at most 160 characters")
        declared_id = metadata.get("id")
        if declared_id is not None and (not isinstance(declared_id, str) or not IDENTIFIER_RE.fullmatch(declared_id)):
            errors.append("metadata.id has an invalid format")
        if set(metadata) - {"id", "name", "description", "labels"}:
            errors.append("metadata contains unsupported properties")
        description = metadata.get("description")
        if description is not None and (not isinstance(description, str) or len(description) > 2000):
            errors.append("metadata.description must be a string of at most 2000 characters")
        labels = metadata.get("labels")
        if labels is not None and (not isinstance(labels, dict) or any(not isinstance(k, str) or not isinstance(val, str) or len(val) > 256 for k, val in labels.items())):
            errors.append("metadata.labels must map strings to strings of at most 256 characters")
    spec = payload.get("spec")
    if not isinstance(spec, dict):
        errors.append("spec must be a JSON object")
    else:
        env_kind = spec.get("environmentKind")
        if not isinstance(env_kind, str) or env_kind not in ENVIRONMENT_KINDS:
            errors.append("spec.environmentKind must be one of the supported environment kinds")
        persistence = spec.get("persistence")
        if persistence is not None and (not isinstance(persistence, str) or persistence not in {"ephemeral", "session", "persistent", "recoverable", "unknown"}):
            errors.append("spec.persistence must be a supported persistence value")
        for key in ("rulesRef", "topologyRef", "parentEnvironmentRef", "provenanceRef"):
            value = spec.get(key)
            if value is not None and (not isinstance(value, str) or len(value) > 512):
                errors.append("spec." + key + " must be a string of at most 512 characters")
        if set(spec) - {"environmentKind", "persistence", "rulesRef", "topologyRef", "parentEnvironmentRef", "provenanceRef"}:
            errors.append("spec contains unsupported properties")
    if set(payload) - {"apiVersion", "kind", "metadata", "spec"}:
        errors.append("manifest contains unsupported top-level properties")
    return errors

def discover(root: Path, candidate_dir: Path) -> dict[str, Any]:
    """Read JSON files below candidate_dir; never mutates files or enrollment state."""
    root = root.resolve()
    directory = candidate_dir if candidate_dir.is_absolute() else root / candidate_dir
    directory = directory.resolve()

    try:
        directory.relative_to(root)
    except ValueError:
        raise ValueError("candidate directory must be inside the configured repository root")

    if not directory.exists():
        return {
            "schema": "wonderland.zone-discovery/v1",
            "mode": "read-only",
            "candidate_count": 0,
            "candidates": [],
            "diagnostics": [{"severity": "info", "code": "candidate_directory_missing",
                             "message": "Candidate directory does not exist; no candidates were read."}],
            "side_effects": False,
        }
    if not directory.is_dir():
        raise ValueError("candidate path is not a directory")

    candidates: list[dict[str, Any]] = []
    diagnostics: list[dict[str, str]] = []
    seen_ids: dict[str, str] = {}
    collided_ids: set[str] = set()

    for path in sorted(directory.glob("*.json"), key=lambda p: p.name):
        relative_source = path.relative_to(root).as_posix()
        if path.is_symlink() or not path.is_file():
            diagnostics.append({"severity": "warning", "code": "non_regular_candidate",
                                "source": path.relative_to(root).as_posix(),
                                "message": "Candidate was skipped because it is not a regular file."})
            continue
        try:
            raw = path.read_bytes()
            payload = json.loads(raw.decode("utf-8"))
        except (OSError, UnicodeError, json.JSONDecodeError) as exc:
            diagnostics.append({"severity": "error", "code": "invalid_json",
                                "source": path.relative_to(root).as_posix(),
                                "message": type(exc).__name__})
            continue
        errors = validate_environment(payload)
        if errors:
            diagnostics.append({"severity": "error", "code": "invalid_environment_manifest",
                                "source": relative_source, "message": "; ".join(errors)})
            continue

        identity, identity_status = candidate_id(path, payload, root)
        if identity in collided_ids:
            diagnostics.append({"severity": "error", "code": "identity_collision",
                                "source": relative_source,
                                "message": "Candidate identity is ambiguous because it appears in multiple manifests; all candidates with this identity are excluded."})
            continue
        if identity in seen_ids:
            first_source = seen_ids.pop(identity)
            candidates = [candidate for candidate in candidates if candidate["id"] != identity]
            collided_ids.add(identity)
            diagnostics.append({"severity": "error", "code": "identity_collision",
                                "source": first_source,
                                "message": "Candidate identity is duplicated by " + relative_source + "; all candidates with this identity are excluded."})
            diagnostics.append({"severity": "error", "code": "identity_collision",
                                "source": relative_source,
                                "message": "Candidate identity duplicates " + first_source + "; all candidates with this identity are excluded."})
            continue
        seen_ids[identity] = relative_source

        metadata = payload["metadata"]
        spec = payload["spec"]
        candidates.append({
            "id": identity,
            "identity_status": identity_status,
            "name": metadata["name"].strip(),
            "environment_kind": spec["environmentKind"],
            "persistence": spec.get("persistence", "unknown"),
            "source": relative_source,
            "source_sha256": hashlib.sha256(raw).hexdigest(),
            "discovery_state": "discovered",
            "enrolled": False,
            "authorized": False,
        })

    return {
        "schema": "wonderland.zone-discovery/v1",
        "mode": "read-only",
        "candidate_count": len(candidates),
        "candidates": candidates,
        "diagnostics": diagnostics,
        "side_effects": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd(),
                        help="Repository root (default: current directory)")
    parser.add_argument("--candidate-dir", type=Path,
                        default=Path("config/wonderland/environments/candidates"),
                        help="Dedicated candidate-manifest directory, relative to --root")
    args = parser.parse_args()
    try:
        result = discover(args.root, args.candidate_dir)
    except (OSError, ValueError) as exc:
        print(json.dumps({"error": type(exc).__name__, "message": str(exc)}, sort_keys=True))
        return 2
    print(json.dumps(result, indent=2, sort_keys=True, ensure_ascii=False))
    return 1 if any(item["severity"] == "error" for item in result["diagnostics"]) else 0


if __name__ == "__main__":
    raise SystemExit(main())
