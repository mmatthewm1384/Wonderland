import unittest
from datetime import datetime, timezone

from wlplatform.mesh.relationship import (
    CapabilityError,
    RelationshipError,
    RelationshipState,
    accept_capability,
    create_capability,
)


class MeshRelationshipTests(unittest.TestCase):
    def setUp(self):
        self.now = datetime(2026, 8, 16, 20, 0, tzinfo=timezone.utc)

    def test_capability_round_trip(self):
        grant = create_capability(
            "participant:alice",
            ["message.send", "artifact.send"],
            now=self.now,
        )
        parsed = grant.from_token(grant.token)
        self.assertEqual(parsed.protocol, "mesh.relationship/1.0")
        self.assertEqual(parsed.issuer, "participant:alice")
        self.assertEqual(parsed.capabilities, ("artifact.send", "message.send"))
        self.assertFalse(parsed.is_expired(self.now))

    def test_capability_is_single_use(self):
        grant = create_capability("participant:alice", ["message.send"], now=self.now)
        consumed = set()
        relationship = accept_capability(
            grant.token,
            "participant:bob",
            now=self.now,
            used_capabilities=consumed,
        )
        self.assertEqual(relationship.state, RelationshipState.ACTIVE)
        self.assertIn(grant.digest, consumed)
        with self.assertRaises(CapabilityError):
            accept_capability(
                grant.token,
                "participant:carol",
                now=self.now,
                used_capabilities=consumed,
            )

    def test_expired_capability_is_rejected(self):
        grant = create_capability(
            "participant:alice",
            ["message.send"],
            ttl_seconds=60,
            now=self.now,
        )
        with self.assertRaises(CapabilityError):
            accept_capability(
                grant.token,
                "participant:bob",
                now=self.now.replace(minute=1, second=1),
            )

    def test_self_acceptance_is_rejected(self):
        grant = create_capability("participant:alice", ["message.send"], now=self.now)
        with self.assertRaises(CapabilityError):
            accept_capability(grant.token, "participant:alice", now=self.now)

    def test_state_machine(self):
        grant = create_capability("participant:alice", ["message.send"], now=self.now)
        relationship = accept_capability(grant.token, "participant:bob", now=self.now)
        relationship.transition(RelationshipState.SUSPENDED, reason="operator hold")
        relationship.transition(RelationshipState.ACTIVE)
        relationship.transition(RelationshipState.REVOKED)
        with self.assertRaises(RelationshipError):
            relationship.transition(RelationshipState.ACTIVE)
        self.assertEqual(relationship.state, RelationshipState.REVOKED)
        self.assertEqual(relationship.evidence[0]["event"], "relationship.established")
        self.assertEqual(relationship.evidence[-1]["to"], "revoked")

    def test_serialized_relationship_is_canonical_shape(self):
        grant = create_capability("participant:alice", ["message.send"], now=self.now)
        relationship = accept_capability(grant.token, "participant:bob", now=self.now)
        value = relationship.to_dict()
        self.assertEqual(value["protocol"], "mesh.relationship/1.0")
        self.assertEqual(value["initiator"], "participant:alice")
        self.assertEqual(value["acceptor"], "participant:bob")
        self.assertEqual(value["state"], "active")
        self.assertEqual(len(value["capability_digest"]), 64)


if __name__ == "__main__":
    unittest.main()
