import sys
import unittest
from datetime import UTC, datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

for path in (
    ROOT,
    ROOT / "XCAVIER-CONTAINMENT-v1",
    ROOT / "XCAVIER-ENFORCEMENT-v1",
):
    if str(path) not in sys.path:
        sys.path.insert(0, str(path))

import enforcement
from authorization_authority import CrystalAuthorizationAuthority
from validator import validate_action

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


def valid_record():
    return {
        "action_id": "act-001",
        "authorization_id": "auth-001",
        "subject_id": "person-001",
        "actor_id": "actor-001",
        "action": "share selected document",
        "purpose": "requested transfer",
        "boundary": "information",
        "authorization": valid_authorization(),
    }


def make_authority(authorization=None):
    current = authorization if authorization is not None else valid_authorization()

    def read_current(authorization_id):
        if authorization_id != "auth-001":
            return None

        return {
            "authorization": current,
            "revision": "test-crystal-revision-001",
        }

    return CrystalAuthorizationAuthority(read_current)


class ContainmentTests(unittest.TestCase):
    def test_valid_record(self):
        result = validate_action(valid_record(), NOW)
        self.assertTrue(result.valid)

    def test_missing_authorization(self):
        record = valid_record()
        del record["authorization"]

        result = validate_action(record, NOW)

        self.assertFalse(result.valid)

    def test_subject_mismatch(self):
        record = valid_record()
        record["authorization"]["subject_id"] = "other"

        result = validate_action(record, NOW)

        self.assertEqual(
            result.code,
            "AUTHORIZATION_BINDING_MISMATCH",
        )

    def test_revoked_authorization(self):
        record = valid_record()
        record["authorization"]["revoked"] = True

        result = validate_action(record, NOW)

        self.assertFalse(result.valid)

    def test_expired_authorization(self):
        record = valid_record()
        record["authorization"]["expires_at"] = "2029-12-31T23:59:59Z"

        result = validate_action(record, NOW)

        self.assertEqual(
            result.code,
            "AUTHORIZATION_EXPIRED",
        )


class EnforcementTests(unittest.TestCase):
    def test_accept_valid_operation(self):
        decision = enforcement.decide(
            valid_record(),
            NOW,
            authority=make_authority(),
        )

        self.assertEqual(decision.outcome, "ACCEPT")
        self.assertEqual(decision.code, "PASS")
        self.assertEqual(
            decision.authorization_revision,
            "test-crystal-revision-001",
        )

    def test_reject_invalid_operation(self):
        record = valid_record()
        record["action"] = "different action"

        decision = enforcement.decide(
            record,
            NOW,
            authority=make_authority(),
        )

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(
            decision.code,
            "AUTHORIZATION_BINDING_MISMATCH",
        )

    def test_reject_malformed_input(self):
        decision = enforcement.decide(None, NOW)

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(decision.code, "RECORD_INVALID")

    def test_decision_ids_are_unique(self):
        authority = make_authority()

        first = enforcement.decide(valid_record(), NOW, authority=authority)
        second = enforcement.decide(valid_record(), NOW, authority=authority)

        self.assertNotEqual(
            first.decision_id,
            second.decision_id,
        )

    def test_caller_supplied_authorization_cannot_override_crystal(self):
        record = valid_record()
        record["authorization"]["revoked"] = False

        authoritative = valid_authorization()
        authoritative["revoked"] = True

        decision = enforcement.decide(
            record,
            NOW,
            authority=make_authority(authoritative),
        )

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(
            decision.code,
            "AUTHORIZATION_REVOKED_OR_UNKNOWN",
        )

    def test_missing_authority_fails_closed(self):
        decision = enforcement.decide(valid_record(), NOW)

        self.assertEqual(decision.outcome, "REJECT")
        self.assertEqual(decision.code, "AUTHORITY_UNAVAILABLE")


if __name__ == "__main__":
    unittest.main()
