import sys
import unittest
from datetime import UTC, datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENFORCEMENT_DIR = ROOT / "XCAVIER-ENFORCEMENT-v1"

for path in (ROOT, ENFORCEMENT_DIR):
    if str(path) not in sys.path:
        sys.path.insert(0, str(path))

from authorization_authority import (
    CrystalAuthorizationAuthority,
)
from enforcement import decide_transition
from XCAVIER_CONTAINMENT import validate_transition

NOW = datetime(2030, 1, 1, tzinfo=UTC)


def valid_authorization():
    return {
        "subject_id": "person-001",
        "actor_id": "actor-001",
        "action": "share selected document",
        "purpose": "requested transfer",
        "informed": True,
        "freely_given": True,
        "revoked": False,
        "expires_at": "2030-01-01T00:05:00Z",
    }


def valid_action_record():
    return {
        "action_id": "act-001",
        "authorization_id": "auth-001",
        "subject_id": "person-001",
        "actor_id": "actor-001",
        "action": "share selected document",
        "purpose": "requested transfer",
        "boundary": "information",
    }


class FakeCrystalReader:
    """Deterministic test double for the Crystal read interface."""

    def __init__(self, record=None):
        self.record = record
        self.calls = []

    def __call__(self, authorization_id):
        self.calls.append(authorization_id)
        return self.record


_DEFAULT = object()


def crystal_record(
    authorization=_DEFAULT,
    revision="crystal-rev-001",
):
    if authorization is _DEFAULT:
        authorization = valid_authorization()

    return {
        "authorization": authorization,
        "revision": revision,
    }


def make_authority(record=_DEFAULT):
    if record is _DEFAULT:
        record = crystal_record()

    reader = FakeCrystalReader(record)
    authority = CrystalAuthorizationAuthority(reader)
    return authority, reader


class TransitionValidationTests(unittest.TestCase):
    def assert_valid(self, current, target, version):
        result = validate_transition(current, target, version, version)
        self.assertTrue(result.valid, result.reason)
        self.assertEqual(result.code, "PASS")

    def assert_invalid(self, current, target, expected_version, current_version):
        result = validate_transition(current, target, expected_version, current_version)
        self.assertFalse(result.valid)

    def test_draft_to_proposed(self):
        self.assert_valid("DRAFT", "PROPOSED", 1)

    def test_proposed_to_validated(self):
        self.assert_valid("PROPOSED", "VALIDATED", 2)

    def test_validated_to_authorized(self):
        self.assert_valid("VALIDATED", "AUTHORIZED", 3)

    def test_authorized_to_accepted(self):
        self.assert_valid("AUTHORIZED", "ACCEPTED", 4)

    def test_accepted_to_in_progress(self):
        self.assert_valid("ACCEPTED", "IN_PROGRESS", 5)

    def test_in_progress_to_completed(self):
        self.assert_valid("IN_PROGRESS", "COMPLETED", 6)

    def test_invalid_transition(self):
        self.assert_invalid("DRAFT", "COMPLETED", 1, 1)

    def test_completed_cannot_restart(self):
        self.assert_invalid("COMPLETED", "DRAFT", 7, 7)

    def test_rejected_cannot_restart(self):
        self.assert_invalid("REJECTED", "PROPOSED", 7, 7)

    def test_revoked_cannot_restart(self):
        self.assert_invalid("REVOKED", "AUTHORIZED", 7, 7)

    def test_expired_cannot_restart(self):
        self.assert_invalid("EXPIRED", "AUTHORIZED", 7, 7)

    def test_cancelled_cannot_restart(self):
        self.assert_invalid("CANCELLED", "PROPOSED", 7, 7)

    def test_failed_cannot_restart(self):
        self.assert_invalid("FAILED", "IN_PROGRESS", 7, 7)

    def test_stale_version(self):
        self.assert_invalid("PROPOSED", "VALIDATED", 2, 3)

    def test_boolean_version(self):
        self.assert_invalid("DRAFT", "PROPOSED", True, 1)

    def test_negative_version(self):
        self.assert_invalid("DRAFT", "PROPOSED", -1, 1)

    def test_unknown_current_state(self):
        self.assert_invalid("UNKNOWN", "PROPOSED", 1, 1)

    def test_unhashable_current_state_is_rejected(self):
        self.assert_invalid([], "PROPOSED", 1, 1)

    def test_unhashable_target_state_is_rejected(self):
        self.assert_invalid("DRAFT", [], 1, 1)


class CrystalAuthorityTests(unittest.TestCase):
    def test_authority_returns_current_snapshot(self):
        record = crystal_record(revision="rev-42")
        authority, reader = make_authority(record)

        snapshot = authority.get_current_authorization("auth-001")

        self.assertIsNotNone(snapshot)
        self.assertEqual(snapshot.revision, "rev-42")
        self.assertEqual(
            snapshot.authorization["subject_id"],
            "person-001",
        )
        self.assertEqual(reader.calls, ["auth-001"])

    def test_missing_authorization_returns_none(self):
        authority, _ = make_authority(None)

        snapshot = authority.get_current_authorization("auth-missing")

        self.assertIsNone(snapshot)

    def test_invalid_identifier_returns_none_without_read(self):
        authority, reader = make_authority()

        self.assertIsNone(authority.get_current_authorization(""))
        self.assertEqual(reader.calls, [])

    def test_invalid_reader_is_rejected(self):
        with self.assertRaises(TypeError):
            CrystalAuthorizationAuthority(None)

    def test_missing_revision_is_rejected(self):
        authority, _ = make_authority(
            {
                "authorization": valid_authorization(),
                "revision": None,
            }
        )

        with self.assertRaises(ValueError):
            authority.get_current_authorization("auth-001")


class TransitionEnforcementTests(unittest.TestCase):
    def decide_protected(
        self,
        *,
        authorization=None,
        record=None,
        revision="crystal-rev-001",
        now=NOW,
    ):
        authority, reader = make_authority(
            crystal_record(
                authorization=(
                    authorization if authorization is not None else valid_authorization()
                ),
                revision=revision,
            )
        )

        decision = decide_transition(
            "VALIDATED",
            "AUTHORIZED",
            3,
            3,
            action_record=(record if record is not None else valid_action_record()),
            authorization_id="auth-001",
            authority=authority,
            now=now,
        )
        return decision, reader

    def test_valid_authorization_is_accepted(self):
        decision, reader = self.decide_protected()

        self.assertEqual(decision.outcome, "ACCEPT")
        self.assertEqual(decision.code, "PASS")
        self.assertEqual(
            decision.authorization_id,
            "auth-001",
        )
        self.assertEqual(
            decision.authorization_revision,
            "crystal-rev-001",
        )
        self.assertEqual(reader.calls, ["auth-001"])

    def test_revoked_authorization_is_rejected(self):
        authorization = valid_authorization()
        authorization["revoked"] = True

        decision, _ = self.decide_protected(authorization=authorization)

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(
            decision.code,
            "AUTHORIZATION_REVOKED_OR_UNKNOWN",
        )

    def test_expired_authorization_is_rejected(self):
        authorization = valid_authorization()
        authorization["expires_at"] = "2029-12-31T23:59:59Z"

        decision, _ = self.decide_protected(authorization=authorization)

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(
            decision.code,
            "AUTHORIZATION_EXPIRED",
        )

    def test_subject_substitution_is_rejected(self):
        authorization = valid_authorization()
        authorization["subject_id"] = "person-other"

        decision, _ = self.decide_protected(authorization=authorization)

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(
            decision.code,
            "AUTHORIZATION_BINDING_MISMATCH",
        )

    def test_actor_substitution_is_rejected(self):
        authorization = valid_authorization()
        authorization["actor_id"] = "actor-other"

        decision, _ = self.decide_protected(authorization=authorization)

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(
            decision.code,
            "AUTHORIZATION_BINDING_MISMATCH",
        )

    def test_missing_authority_is_rejected(self):
        decision = decide_transition(
            "VALIDATED",
            "AUTHORIZED",
            1,
            1,
            action_record=valid_action_record(),
            authorization_id="auth-001",
        )

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(decision.code, "AUTHORITY_UNAVAILABLE")

    def test_missing_authorization_is_rejected(self):
        authority, _ = make_authority(None)

        decision = decide_transition(
            "VALIDATED",
            "AUTHORIZED",
            1,
            1,
            action_record=valid_action_record(),
            authorization_id="auth-001",
            authority=authority,
        )

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(decision.code, "AUTHORIZATION_NOT_FOUND")

    def test_authorization_id_mismatch_is_rejected(self):
        record = valid_action_record()
        record["authorization_id"] = "auth-other"

        decision, reader = self.decide_protected(record=record)

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(
            decision.code,
            "AUTHORIZATION_ID_MISMATCH",
        )
        self.assertEqual(reader.calls, [])

    def test_stale_version_is_rejected_before_authority_read(self):
        authority, reader = make_authority()

        decision = decide_transition(
            "VALIDATED",
            "AUTHORIZED",
            2,
            3,
            action_record=valid_action_record(),
            authorization_id="auth-001",
            authority=authority,
        )

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(decision.code, "STATE_VERSION_CONFLICT")
        self.assertEqual(reader.calls, [])

    def test_non_protected_transition_needs_no_authority(self):
        decision = decide_transition(
            "DRAFT",
            "PROPOSED",
            1,
            1,
        )

        self.assertEqual(decision.outcome, "ACCEPT")
        self.assertEqual(decision.code, "PASS")

    def test_revocation_exit_does_not_require_valid_authorization(self):
        decision = decide_transition(
            "AUTHORIZED",
            "REVOKED",
            4,
            4,
        )

        self.assertEqual(decision.outcome, "ACCEPT")
        self.assertEqual(decision.code, "PASS")

    def test_caller_supplied_authorization_is_not_trusted(self):
        record = valid_action_record()
        record["authorization"] = valid_authorization()
        record["authorization"]["revoked"] = False

        authoritative = valid_authorization()
        authoritative["revoked"] = True

        decision, _ = self.decide_protected(
            authorization=authoritative,
            record=record,
        )

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(
            decision.code,
            "AUTHORIZATION_REVOKED_OR_UNKNOWN",
        )

    def test_decision_ids_are_unique(self):
        first, _ = self.decide_protected()
        second, _ = self.decide_protected()

        self.assertNotEqual(first.decision_id, second.decision_id)

    def test_authority_read_failure_fails_closed(self):
        def failing_reader(_authorization_id):
            raise OSError("Crystal unavailable")

        authority = CrystalAuthorizationAuthority(failing_reader)

        decision = decide_transition(
            "VALIDATED",
            "AUTHORIZED",
            1,
            1,
            action_record=valid_action_record(),
            authorization_id="auth-001",
            authority=authority,
        )

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(
            decision.code,
            "TRANSITION_VALIDATION_ERROR",
        )


if __name__ == "__main__":
    unittest.main()
