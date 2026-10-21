#!/usr/bin/env python3
"""Read-only deterministic discovery for Mattie's Room candidate manifests."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


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

    for path in sorted(directory.glob("*.json"), key=lambda p: p.name):
        if path.is_symlink() or not path.is_file():
            diagnostics.append({"severity": "warning", "code": "non_regular_candidate",
                                "source": path.relative_to(root).as_posix(),
                                "message": "Candidate was skipped because it is not a regular file."})
            continue
        try:
            payload = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, UnicodeError, json.JSONDecodeError) as exc:
            diagnostics.append({"severity": "error", "code": "invalid_json",
                                "source": path.relative_to(root).as_posix(),
                                "message": type(exc).__name__})
            continue
        if not isinstance(payload, dict) or payload.get("kind") != "Environment":
            diagnostics.append({"severity": "warning", "code": "unsupported_manifest",
                                "source": path.relative_to(root).as_posix(),
                                "message": "Expected a JSON object with kind=Environment; candidate was skipped."})
            continue

        metadata = payload.get("metadata", {})
        spec = payload.get("spec", {})
        if not isinstance(metadata, dict) or not isinstance(spec, dict):
            diagnostics.append({"severity": "error", "code": "invalid_shape",
                                "source": path.relative_to(root).as_posix(),
                                "message": "metadata and spec must be JSON objects."})
            continue

        identity, identity_status = candidate_id(path, payload, root)
        relative_source = path.relative_to(root).as_posix()
        if identity in seen_ids:
            diagnostics.append({"severity": "error", "code": "identity_collision",
                                "source": relative_source,
                                "message": "Candidate identity duplicates " + seen_ids[identity] + "; neither candidate is enrolled."})
            continue
        seen_ids[identity] = relative_source

        env_kind = spec.get("environmentKind", "unknown")
        if env_kind not in {"physical", "virtual", "simulated", "imagined", "abstract", "hybrid", "computational"}:
            diagnostics.append({"severity": "warning", "code": "unknown_environment_kind",
                                "source": relative_source,
                                "message": "Environment kind is missing or unrecognized."})
            env_kind = "unknown"

        candidates.append({
            "id": identity,
            "identity_status": identity_status,
            "name": str(metadata.get("name") or identity),
            "environment_kind": env_kind,
            "source": relative_source,
            "source_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
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
