"""Canonical local reference implementation of ``mesh.relationship.v1``."""

from __future__ import annotations

import uuid
from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Any

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

from .capability import SignedCapability, create_signed_capability

PROTOCOL = "mesh.relationship/1.0"
DEFAULT_CAPABILITY_TTL_SECONDS = 15 * 60


class RelationshipError(ValueError):
    """Base error for invalid relationship operations."""


class CapabilityError(RelationshipError):
    """Raised when a relationship capability is invalid or unusable."""


class RelationshipState(str, Enum):
    PENDING = "pending"
    ACTIVE = "active"
    SUSPENDED = "suspended"
    REVOKED = "revoked"
    EXPIRED = "expired"
    REJECTED = "rejected"


_ALLOWED_TRANSITIONS = {
    RelationshipState.PENDING: frozenset({RelationshipState.ACTIVE, RelationshipState.REJECTED, RelationshipState.EXPIRED}),
    RelationshipState.ACTIVE: frozenset({RelationshipState.SUSPENDED, RelationshipState.REVOKED, RelationshipState.EXPIRED}),
    RelationshipState.SUSPENDED: frozenset({RelationshipState.ACTIVE, RelationshipState.REVOKED, RelationshipState.EXPIRED}),
    RelationshipState.REVOKED: frozenset(),
    RelationshipState.EXPIRED: frozenset(),
    RelationshipState.REJECTED: frozenset(),
}


def _timestamp(value: datetime) -> str:
    return value.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


@dataclass(frozen=True)
class CapabilityGrant:
    """Compatibility wrapper around a cryptographically signed capability."""

    signed: SignedCapability

    @property
    def protocol(self) -> str: return self.signed.protocol
    @property
    def issuer(self) -> str: return self.signed.issuer
    @property
    def capabilities(self) -> tuple[str, ...]: return self.signed.capabilities
    @property
    def issued_at(self) -> str: return self.signed.issued_at
    @property
    def expires_at(self) -> str: return self.signed.expires_at
    @property
    def nonce(self) -> str: return self.signed.nonce
    @property
    def token(self) -> str: return self.signed.token
    @property
    def digest(self) -> str: return self.signed.digest
    @property
    def key_fingerprint(self) -> str: return self.signed.key_fingerprint

    def is_expired(self, now: datetime | None = None) -> bool:
        return self.signed.is_expired(now)

    @classmethod
    def from_token(cls, token: str) -> "CapabilityGrant":
        return cls(SignedCapability.parse(token))

    def verify(self, *, now: datetime | None = None) -> None:
        self.signed.verify(now=now)


@dataclass
class Relationship:
    relationship_id: str
    initiator: str
    acceptor: str
    capabilities: tuple[str, ...]
    state: RelationshipState
    created_at: str
    updated_at: str
    capability_digest: str
    issuer_key_fingerprint: str
    evidence: list[dict[str, Any]] = field(default_factory=list)

    def transition(self, state: RelationshipState, *, reason: str | None = None) -> None:
        if state == self.state:
            return
        if state not in _ALLOWED_TRANSITIONS[self.state]:
            raise RelationshipError(f"invalid relationship transition: {self.state.value} -> {state.value}")
        now = _timestamp(datetime.now(timezone.utc))
        event: dict[str, Any] = {"event": "relationship.transition", "from": self.state.value, "to": state.value, "at": now}
        if reason:
            event["reason"] = reason
        self.state = state
        self.updated_at = now
        self.evidence.append(event)

    def to_dict(self) -> dict[str, Any]:
        return {
            "protocol": PROTOCOL,
            "relationship_id": self.relationship_id,
            "initiator": self.initiator,
            "acceptor": self.acceptor,
            "capabilities": list(self.capabilities),
            "state": self.state.value,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "capability_digest": self.capability_digest,
            "issuer_key_fingerprint": self.issuer_key_fingerprint,
            "evidence": list(self.evidence),
        }


def create_capability(issuer: str, capabilities: list[str] | tuple[str, ...], private_key: Ed25519PrivateKey, *, ttl_seconds: int = DEFAULT_CAPABILITY_TTL_SECONDS, now: datetime | None = None) -> CapabilityGrant:
    return CapabilityGrant(create_signed_capability(issuer, capabilities, private_key, ttl_seconds=ttl_seconds, now=now))


def accept_capability(token: str, acceptor: str, *, now: datetime | None = None, used_capabilities: set[str] | None = None) -> Relationship:
    if not acceptor:
        raise CapabilityError("acceptor is required")
    grant = CapabilityGrant.from_token(token)
    try:
        grant.verify(now=now)
    except ValueError as exc:
        raise CapabilityError(str(exc)) from exc
    if acceptor == grant.issuer:
        raise CapabilityError("acceptor must differ from issuer")
    consumed = used_capabilities if used_capabilities is not None else set()
    if grant.digest in consumed:
        raise CapabilityError("capability has already been consumed")
    consumed.add(grant.digest)
    timestamp = _timestamp((now or datetime.now(timezone.utc)).astimezone(timezone.utc))
    return Relationship(
        relationship_id=str(uuid.uuid4()), initiator=grant.issuer, acceptor=acceptor,
        capabilities=grant.capabilities, state=RelationshipState.ACTIVE,
        created_at=timestamp, updated_at=timestamp, capability_digest=grant.digest,
        issuer_key_fingerprint=grant.key_fingerprint,
        evidence=[{"event": "relationship.established", "at": timestamp, "capability_digest": grant.digest}],
    )
