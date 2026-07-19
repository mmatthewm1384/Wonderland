from __future__ import annotations

from pathlib import Path
import json


def load_repository_evidence(root: Path) -> dict:
    candidates = [
        root / ".state/repository/certificate.json",
        root / "vault/08-Operations/certifications",
    ]

    certificate = None

    state = candidates[0]

    if state.exists():
        try:
            certificate = json.loads(
                state.read_text(encoding="utf-8")
            )
        except Exception:
            certificate = None

    if not certificate:
        return {
            "engine": "repository",
            "certified": False,
            "status": "MISSING",
            "evidence": None,
        }

    result = (
        certificate.get("result")
        or certificate.get("verification")
        or "UNKNOWN"
    )

    if isinstance(result, str):
        certified = result == "PASS"
    else:
        certified = bool(
            certificate.get("certified", False)
        )

    return {
        "engine": "repository",
        "certified": certified,
        "status": "PASS" if certified else "FAIL",
        "evidence": {
            "policy_digest": certificate.get(
                "policy_digest"
            ),
            "generated_digest": certificate.get(
                "generated_digest"
            ),
            "state_digest": certificate.get(
                "state_digest"
            ),
            "checks": certificate.get(
                "checks",
                {}
            ),
        },
    }
