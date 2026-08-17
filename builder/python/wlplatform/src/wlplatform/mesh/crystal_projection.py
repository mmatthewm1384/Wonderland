"""Crystal projection and recovery for Mesh relationships.

The projection is a canonical, deterministic representation of a relationship
suitable for insertion into a Crystal object store. It deliberately contains
no private key material and does not perform object encryption; the existing
Crystal object layer owns encryption, addressing, and physical persistence.

This module establishes the boundary:

    SQLite operational state -> canonical Crystal object -> recovery

A recovered relationship is validated from the canonical object rather than
trusting SQLite-derived state.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from typing import Any, Mapping

from .relationship import PROTOCOL, Relationship, RelationshipState


CRYSTAL_PROJECTION_PROTOCOL = "crystal.mesh.relationship/1.0"
CRYSTAL_OBJECT_TYPE = "mesh.relationship"
CANONICAL_ENCODING = "utf-8"


class CrystalProjectionError(ValueError):
    """Raised when a relationship cannot be projected or recovered safely."""


@dataclass(frozen=True)
class CrystalRelationshipObject:
    """Canonical plaintext envelope handed to the Crystal object layer."""

    object_id: str
    object_type: str
    protocol: str
    payload: dict[str, Any]
    payload_sha256: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "object_id": self.object_id,
            "object_type": self.object_type,
            "protocol": self.protocol,
            "payload": self.payload,
            "payload_sha256": self.payload_sha256,
        }


def _canonical_bytes(value: Mapping[str, Any]) -> bytes:
    return json.dumps(
        value,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=False,
    ).encode(CANONICAL_ENCODING)


def _digest(value: Mapping[str, Any]) -> str:
    return hashlib.sha256(_canonical_bytes(value)).hexdigest()


def _validate_payload(payload: Mapping[str, Any]) -> None:
    required = {
        "protocol",
        "relationship_id",
        "initiator",
        "acceptor",
        "capabilities",
        "state",
        "created_at",
        "updated_at",
        "capability_digest",
        "evidence",
    }
    if set(payload) != required:
        raise CrystalProjectionError("relationship payload fields are invalid")
    if payload["protocol"] != PROTOCOL:
        raise CrystalProjectionError("unsupported relationship protocol")
    if not isinstance(payload["relationship_id"], str) or not payload["relationship_id"]:
        raise CrystalProjectionError("relationship_id is required")
    if payload["initiator"] == payload["acceptor"]:
        raise CrystalProjectionError("initiator and acceptor must differ")
    if not isinstance(payload["capabilities"], list) or not payload["capabilities"]:
        raise CrystalProjectionError("capabilities must be a non-empty list")
    if not all(isinstance(item, str) and item for item in payload["capabilities"]):
        raise CrystalProjectionError("capabilities must contain non-empty strings")
    if payload["state"] not in {state.value for state in RelationshipState}:
        raise CrystalProjectionError("invalid relationship state")
    if not isinstance(payload["evidence"], list):
        raise CrystalProjectionError("evidence must be a list")
    digest = payload["capability_digest"]
    if not isinstance(digest, str) or len(digest) != 64 or any(
        char not in "0123456789abcdef" for char in digest
    ):
        raise CrystalProjectionError("invalid capability digest")


def project_relationship(relationship: Relationship) -> CrystalRelationshipObject:
    """Project a relationship into a deterministic Crystal object envelope."""

    if not isinstance(relationship, Relationship):
        raise CrystalProjectionError("expected Relationship")

    payload = relationship.to_dict()
    payload_digest = _digest(payload)
    return CrystalRelationshipObject(
        object_id=f"relationship:{relationship.relationship_id}",
        object_type=CRYSTAL_OBJECT_TYPE,
        protocol=CRYSTAL_PROJECTION_PROTOCOL,
        payload=payload,
        payload_sha256=payload_digest,
    )


def serialize_projection(obj: CrystalRelationshipObject) -> bytes:
    """Serialize the projection deterministically for a Crystal object writer."""

    envelope = obj.to_dict()
    return _canonical_bytes(envelope)


def recover_relationship(
    obj: CrystalRelationshipObject | Mapping[str, Any] | bytes | str,
) -> Relationship:
    """Recover a relationship solely from a verified canonical projection."""

    if isinstance(obj, CrystalRelationshipObject):
        envelope = obj.to_dict()
    elif isinstance(obj, bytes):
        try:
            envelope = json.loads(obj.decode(CANONICAL_ENCODING))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise CrystalProjectionError("invalid Crystal projection encoding") from exc
    elif isinstance(obj, str):
        try:
            envelope = json.loads(obj)
        except json.JSONDecodeError as exc:
            raise CrystalProjectionError("invalid Crystal projection JSON") from exc
    elif isinstance(obj, Mapping):
        envelope = dict(obj)
    else:
        raise CrystalProjectionError("unsupported Crystal projection type")

    required = {"object_id", "object_type", "protocol", "payload", "payload_sha256"}
    if set(envelope) != required:
        raise CrystalProjectionError("Crystal envelope fields are invalid")
    if envelope["object_type"] != CRYSTAL_OBJECT_TYPE:
        raise CrystalProjectionError("unexpected Crystal object type")
    if envelope["protocol"] != CRYSTAL_PROJECTION_PROTOCOL:
        raise CrystalProjectionError("unsupported Crystal projection protocol")
    if not isinstance(envelope["payload"], dict):
        raise CrystalProjectionError("Crystal payload must be an object")

    payload = envelope["payload"]
    _validate_payload(payload)
    expected_digest = _digest(payload)
    if envelope["payload_sha256"] != expected_digest:
        raise CrystalProjectionError("Crystal payload digest mismatch")
    expected_object_id = f"relationship:{payload['relationship_id']}"
    if envelope["object_id"] != expected_object_id:
        raise CrystalProjectionError("Crystal object_id does not match relationship_id")

    return Relationship(
        relationship_id=payload["relationship_id"],
        initiator=payload["initiator"],
        acceptor=payload["acceptor"],
        capabilities=tuple(payload["capabilities"]),
        state=RelationshipState(payload["state"]),
        created_at=payload["created_at"],
        updated_at=payload["updated_at"],
        capability_digest=payload["capability_digest"],
        evidence=list(payload["evidence"]),
    )


def verify_projection(obj: CrystalRelationshipObject | Mapping[str, Any] | bytes | str) -> str:
    """Verify a projection and return its payload SHA-256 digest."""

    recovered = recover_relationship(obj)
    return project_relationship(recovered).payload_sha256
