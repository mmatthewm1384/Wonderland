from __future__ import annotations

import json
from pathlib import Path

from wlplatform.certification_registry import CertificationRegistry
from wlplatform.verification import PlatformVerificationEngine


ROOT = Path(__file__).resolve().parents[5]


CERT_ROOT = (
    ROOT
    / "vault/08-Operations/certifications"
)


def test_active_engines_have_status():
    registry = CertificationRegistry(ROOT)

    active = registry.normalize_active()

    assert active, "active certification registry is empty"

    missing = [
        name
        for name, engine in active.items()
        if "status" not in engine
        or engine["status"] is None
    ]

    assert not missing, (
        "engines missing certification status: "
        + ", ".join(missing)
    )


def test_certified_engines_have_certified_true():
    registry = CertificationRegistry(ROOT)

    active = registry.normalize_active()

    invalid = [
        name
        for name, engine in active.items()
        if engine.get("certified") is True
        and engine.get("status") != "PASS"
    ]

    assert not invalid, (
        "certified engines without PASS status: "
        + ", ".join(invalid)
    )


def test_platform_summary_matches_verification():
    summary_file = (
        CERT_ROOT
        / "normalized"
        / "platform-certification.json"
    )

    assert summary_file.exists()

    summary = json.loads(
        summary_file.read_text()
    )

    verification = (
        PlatformVerificationEngine(ROOT)
        .verify()
    )

    expected = (
        verification["result"]
        == "PASS"
    )

    assert summary["certified"] == expected

    assert (
        summary["status"]
        == (
            "PASS"
            if expected
            else "FAIL"
        )
    )

    assert summary["trust"] == "COMPLETE"
