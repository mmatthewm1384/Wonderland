import unittest
from datetime import datetime, timezone
import json

from wlplatform.mesh.crystal_projection import (
    CrystalProjectionError,
    project_relationship,
    recover_relationship,
    serialize_projection,
    verify_projection,
)
from wlplatform.mesh.relationship import RelationshipState, accept_capability, create_capability


class CrystalProjectionTests(unittest.TestCase):
    def setUp(self):
        self.now = datetime(2026, 8, 16, 20, 0, tzinfo=timezone.utc)
        grant = create_capability("participant:alice", ["message.send"], now=self.now)
        self.relationship = accept_capability(
            grant.token,
            "participant:bob",
            now=self.now,
        )

    def test_projection_is_deterministic(self):
        first = project_relationship(self.relationship)
        second = project_relationship(self.relationship)
        self.assertEqual(first.to_dict(), second.to_dict())
        self.assertEqual(serialize_projection(first), serialize_projection(second))

    def test_round_trip_recovery(self):
        projected = project_relationship(self.relationship)
        recovered = recover_relationship(serialize_projection(projected))
        self.assertEqual(recovered.to_dict(), self.relationship.to_dict())
        self.assertEqual(verify_projection(projected), projected.payload_sha256)

    def test_recovery_is_independent_of_original_object(self):
        projected = project_relationship(self.relationship)
        recovered = recover_relationship(projected.to_dict())
        recovered.transition(RelationshipState.SUSPENDED)
        self.assertEqual(self.relationship.state, RelationshipState.ACTIVE)
        self.assertEqual(recovered.state, RelationshipState.SUSPENDED)

    def test_payload_tamper_is_detected(self):
        projected = project_relationship(self.relationship).to_dict()
        projected["payload"]["state"] = "revoked"
        with self.assertRaises(CrystalProjectionError):
            recover_relationship(projected)

    def test_digest_tamper_is_detected(self):
        projected = project_relationship(self.relationship).to_dict()
        projected["payload_sha256"] = "0" * 64
        with self.assertRaises(CrystalProjectionError):
            recover_relationship(projected)

    def test_object_id_binding_is_detected(self):
        projected = project_relationship(self.relationship).to_dict()
        projected["object_id"] = "relationship:00000000-0000-0000-0000-000000000000"
        with self.assertRaises(CrystalProjectionError):
            recover_relationship(projected)

    def test_serialized_json_is_canonical(self):
        projected = project_relationship(self.relationship)
        raw = serialize_projection(projected)
        parsed = json.loads(raw.decode("utf-8"))
        self.assertEqual(raw, serialize_projection(recover_projection(parsed)))


def recover_projection(value):
    return project_relationship(recover_relationship(value))


if __name__ == "__main__":
    unittest.main()
