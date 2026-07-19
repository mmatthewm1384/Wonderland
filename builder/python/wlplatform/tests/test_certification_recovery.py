"""
Certification Recovery Verification
"""

import json
from pathlib import Path


ROOT = Path(
    "vault/08-Operations/certifications/"
    "certification-engine-1.1"
)


def test_recovery_state_exists():

    state = (
        ROOT /
        "recovery" /
        "recovery-state.json"
    )

    assert state.exists()


def test_recovery_is_verified():

    state = (
        ROOT /
        "recovery" /
        "recovery-state.json"
    )

    data = json.loads(
        state.read_text()
    )

    assert (
        data["recovery"]["status"]
        ==
        "VERIFIED"
    )


def test_recovery_steps_complete():

    state = (
        ROOT /
        "recovery" /
        "recovery-state.json"
    )

    data = json.loads(
        state.read_text()
    )

    required = [
        "detect-invalid-state",
        "restore-evidence",
        "recalculate-digest",
        "verify-lineage",
        "restore-certified-state"
    ]

    for step in required:
        assert (
            step
            in
            data["recovery"]["steps"]
        )
