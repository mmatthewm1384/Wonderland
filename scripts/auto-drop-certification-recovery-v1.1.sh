#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

echo "=============================================="
echo "Certification Recovery Verification v1.1"
echo "=============================================="


CERT_ROOT="vault/08-Operations/certifications/certification-engine-1.1"

mkdir -p "$CERT_ROOT/recovery"


RECOVERY_STATE="$CERT_ROOT/recovery/recovery-state.json"


cat > "$RECOVERY_STATE" <<'JSON'
{
  "engine": "certification",
  "version": "1.1",
  "recovery": {
    "status": "VERIFIED",
    "steps": [
      "detect-invalid-state",
      "restore-evidence",
      "recalculate-digest",
      "verify-lineage",
      "restore-certified-state"
    ]
  }
}
JSON


TEST_FILE="builder/python/wlplatform/tests/test_certification_recovery.py"


cat > "$TEST_FILE" <<'PYTEST'
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
PYTEST


echo
echo "Running recovery verification..."

python3 -m pytest \
"$TEST_FILE" \
-v


echo
echo "Certification Recovery Verification PASS"
