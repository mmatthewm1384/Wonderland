import unittest
from datetime import datetime, timedelta, timezone

from wlplatform.mesh.capability import CapabilitySignatureError, generate_keypair
from wlplatform.mesh.relationship import CapabilityError, RelationshipError, RelationshipState, accept_capability, create_capability


class MeshRelationshipTests(unittest.TestCase):
    def setUp(self):
        self.now = datetime(2026, 8, 16, 20, 0, tzinfo=timezone.utc)
        self.private_key, self.public_key = generate_keypair()

    def test_capability_round_trip_and_signature(self):
        grant = create_capability("participant:alice", ["message.send", "artifact.send"], self.private_key, now=self.now)
        parsed = grant.from_token(grant.token)
        parsed.verify(now=self.now)
        self.assertEqual(parsed.protocol, "mesh.capability/1.0")
        self.assertEqual(parsed.issuer, "participant:alice")
        self.assertEqual(parsed.capabilities, ("artifact.send", "message.send"))
        self.assertEqual(len(parsed.key_fingerprint), 64)

    def test_tampered_capability_is_rejected(self):
        grant = create_capability("participant:alice", ["message.send"], self.private_key, now=self.now)
        parts = grant.token.split(".")
        tampered = f"{parts[0]}.{parts[1][:-1]}A.{parts[2]}"
        with self.assertRaises(CapabilitySignatureError):
            grant.from_token(tampered).verify(now=self.now)

    def test_wrong_key_signature_is_rejected(self):
        grant = create_capability("participant:alice", ["message.send"], self.private_key, now=self.now)
        wrong_private, _ = generate_keypair()
        replacement = create_capability("participant:alice", ["message.send"], wrong_private, now=self.now)
        self.assertNotEqual(grant.key_fingerprint, replacement.key_fingerprint)
        with self.assertRaises(CapabilitySignatureError):
            grant.from_token(replacement.token).verify(now=self.now.replace(microsecond=1))

    def test_capability_is_single_use(self):
        grant = create_capability("participant:alice", ["message.send"], self.private_key, now=self.now)
        consumed = set()
        relationship = accept_capability(grant.token, "participant:bob", now=self.now, used_capabilities=consumed)
        self.assertEqual(relationship.state, RelationshipState.ACTIVE)
        self.assertIn(grant.digest, consumed)
        with self.assertRaises(CapabilityError):
            accept_capability(grant.token, "participant:carol", now=self.now, used_capabilities=consumed)

    def test_expired_capability_is_rejected(self):
        grant = create_capability("participant:alice", ["message.send"], self.private_key, ttl_seconds=60, now=self.now)
        with self.assertRaises(CapabilityError):
            accept_capability(grant.token, "participant:bob", now=self.now + timedelta(seconds=61))

    def test_self_acceptance_is_rejected(self):
        grant = create_capability("participant:alice", ["message.send"], self.private_key, now=self.now)
        with self.assertRaises(CapabilityError):
            accept_capability(grant.token, "participant:alice", now=self.now)

    def test_state_machine(self):
        grant = create_capability("participant:alice", ["message.send"], self.private_key, now=self.now)
        relationship = accept_capability(grant.token, "participant:bob", now=self.now)
        relationship.transition(RelationshipState.SUSPENDED, reason="operator hold")
        relationship.transition(RelationshipState.ACTIVE)
        relationship.transition(RelationshipState.REVOKED)
        with self.assertRaises(RelationshipError):
            relationship.transition(RelationshipState.ACTIVE)
        self.assertEqual(relationship.state, RelationshipState.REVOKED)
        self.assertEqual(relationship.evidence[-1]["to"], "revoked")

    def test_serialized_relationship_contains_cryptographic_binding(self):
        grant = create_capability("participant:alice", ["message.send"], self.private_key, now=self.now)
        relationship = accept_capability(grant.token, "participant:bob", now=self.now)
        value = relationship.to_dict()
        self.assertEqual(value["protocol"], "mesh.relationship/1.0")
        self.assertEqual(value["state"], "active")
        self.assertEqual(len(value["capability_digest"]), 64)
        self.assertEqual(value["issuer_key_fingerprint"], grant.key_fingerprint)


if __name__ == "__main__":
    unittest.main()
