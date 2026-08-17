import tempfile
import unittest
from datetime import datetime, timezone
from pathlib import Path

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

from wlplatform.mesh.relationship import RelationshipState, create_capability, accept_capability
from wlplatform.mesh.relationship_store import (
    CapabilityAlreadyConsumed,
    RelationshipNotFound,
    RelationshipStore,
)


class RelationshipStoreTests(unittest.TestCase):
    def setUp(self):
        self.now = datetime(2026, 8, 16, 20, 0, tzinfo=timezone.utc)
        self.key = Ed25519PrivateKey.generate()
        self.tempdir = tempfile.TemporaryDirectory()
        self.path = Path(self.tempdir.name) / "relationships.db"

    def tearDown(self):
        self.tempdir.cleanup()

    def _relationship(self):
        grant = create_capability(
            "participant:alice", ["message.send", "artifact.send"], self.key, now=self.now
        )
        return accept_capability(grant.token, "participant:bob", now=self.now)

    def test_establish_round_trip_and_restart(self):
        relationship = self._relationship()
        with RelationshipStore(self.path) as store:
            store.establish(relationship, relationship.created_at)
            self.assertEqual(store.count(), 1)
            self.assertEqual(store.integrity_check(), "ok")

        with RelationshipStore(self.path) as reopened:
            restored = reopened.get(relationship.relationship_id)
            self.assertEqual(restored.to_dict(), relationship.to_dict())
            self.assertTrue(reopened.is_capability_consumed(relationship.capability_digest))

    def test_duplicate_capability_is_rejected_atomically(self):
        first = self._relationship()
        second = self._relationship()
        second.capability_digest = first.capability_digest

        with RelationshipStore(self.path) as store:
            store.establish(first, first.created_at)
            with self.assertRaises(CapabilityAlreadyConsumed):
                store.establish(second, second.created_at)
            self.assertEqual(store.count(), 1)

    def test_transition_persists_evidence(self):
        relationship = self._relationship()
        with RelationshipStore(self.path) as store:
            store.establish(relationship, relationship.created_at)
            updated = store.transition(
                relationship.relationship_id,
                RelationshipState.SUSPENDED,
                reason="operator hold",
            )
            self.assertEqual(updated.state, RelationshipState.SUSPENDED)

        with RelationshipStore(self.path) as reopened:
            restored = reopened.get(relationship.relationship_id)
            self.assertEqual(restored.state, RelationshipState.SUSPENDED)
            self.assertEqual(restored.evidence[-1]["reason"], "operator hold")

    def test_invalid_transition_rolls_back(self):
        relationship = self._relationship()
        with RelationshipStore(self.path) as store:
            store.establish(relationship, relationship.created_at)
            with self.assertRaises(ValueError):
                store.transition(relationship.relationship_id, RelationshipState.PENDING)
            self.assertEqual(store.get(relationship.relationship_id).state, RelationshipState.ACTIVE)

    def test_missing_relationship(self):
        with RelationshipStore(self.path) as store:
            with self.assertRaises(RelationshipNotFound):
                store.get("missing")

    def test_state_filter(self):
        relationship = self._relationship()
        with RelationshipStore(self.path) as store:
            store.establish(relationship, relationship.created_at)
            self.assertEqual(len(store.list(state=RelationshipState.ACTIVE)), 1)
            self.assertEqual(len(store.list(state=RelationshipState.REVOKED)), 0)


if __name__ == "__main__":
    unittest.main()
