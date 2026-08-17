"""Canonical local reference implementation of ``mesh.relationship.v1``.

This module defines relationship state and capability semantics only. Network
transport, peer identity, and cryptographic session establishment remain
separate concerns and are intentionally not implemented here.
"""

from __future__ import annotations

import base64
import hashlib
import json
import secrets
import uuid
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from enum import Enum
from typing import Any, Mapping


PROTOCOL = "mesh.relationship/1.0"
CAPABILITY_PREFIX = "wmc1"
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


_ALLOWED_TRANSITIONS: dict[RelationshipState, frozenset[RelationshipState]] = {
    RelationshipState.PENDING: frozenset(
        {RelationshipState.ACTIVE, RelationshipState.REJECTED, RelationshipState.EXPIRED}
    ),
    RelationshipState.ACTIVE: frozenset(
        {RelationshipState.SUSPENDED, RelationshipState.REVOKED, RelationshipState.EXPIRED}
    ),
    RelationshipState.SUSPENDED: frozenset(
        {RelationshipState.ACTIVE, RelationshipState.REVOKED, RelationshipState.EXPIRED}
    ),
    RelationshipState.REVOKED: frozenset(),
    RelationshipState.EXPIRED: frozenset(),
    RelationshipState.REJECTED: frozenset(),
}


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


def _timestamp(value: datetime) -> str:
    return value.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def _parse_timestamp(value: str) -> datetime:
    if not isinstance(value, str):
        raise CapabilityError("timestamp must be a string")
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00")).astimezone(timezone.utc)
    except ValueError as exc:
        raise CapabilityError("invalid timestamp") from exc


def _b64e(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")


def _b64d(value: str) -> bytes:
    try:
        return base64.urlsafe_b64decode(value + "=" * (-len(value) % 4))
    except Exception as exc:  # pragma: no cover - defensive boundary
        raise CapabilityError("invalid capability encoding") from exc


def _canonical_json(value: Mapping[str, Any]) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":")).encode("utf-8")


def _capability_digest(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


@dataclass(frozen=True)
class CapabilityGrant:
    """A one-time capability that permits relationship establishment."""

    protocol: str
    issuer: str
    capabilities: tuple[str, ...]
    issued_at: str
    expires_at: str
    nonce: str
    token: str = field(repr=False)

    @property
    def digest(self) -> str:
        return _capability_digest(self.token)

    def is_expired(self, now: datetime | None = None) -> bool:
        return (now or _utc_now()) >= _parse_timestamp(self.expires_at)

    def to_dict(self) -> dict[str, Any]:
        return {
            "protocol": self.protocol,
            "issuer": self.issuer,
            "capabilities": list(self.capabilities),
            "issued_at": self.issued_at,
            "expires_at": self.expires_at,
            "nonce": self.nonce,
        }

    @classmethod
    def from_token(cls, token: str) -> "CapabilityGrant":
        parts = token.split(".")
        if len(parts) != 3 or parts[0] != CAPABILITY_PREFIX:
            raise CapabilityError("invalid capability prefix")

        payload = _b64d(parts[1])
        try:
            data = json.loads(payload.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise CapabilityError("invalid capability payload") from exc

        required = {"protocol", "issuer", "capabilities", "issued_at", "expires_at", "nonce"}
        if set(data) != required:
            raise CapabilityError("capability payload fields are invalid")
        if data["protocol"] != PROTOCOL:
            raise CapabilityError("unsupported capability protocol")
        if not isinstance(data["issuer"], str) or not data["issuer"]:
            raise CapabilityError("capability issuer is required")
        if not isinstance(data["capabilities"], list) or not all(
            isinstance(item, str) and item for item in data["capabilities"]
        ):
            raise CapabilityError("capabilities must be non-empty strings")
        if not isinstance(data["nonce"], str) or not data["nonce"]:
            raise CapabilityError("capability nonce is required")

        _parse_timestamp(data["issued_at"])
        _parse_timestamp(data["expires_at"])

        return cls(
            protocol=data["protocol"],
            issuer=data["issuer"],
            capabilities=tuple(data["capabilities"]),
            issued_at=data["issued_at"],
            expires_at=data["expires_at"],
            nonce=data["nonce"],
            token=token,
        )


@dataclass
class Relationship:
    """A perspective-independent relationship record."""

    relationship_id: str
    initiator: str
    acceptor: str
    capabilities: tuple[str, ...]
    state: RelationshipState
    created_at: str
    updated_at: str
    capability_digest: str
    evidence: list[dict[str, Any]] = field(default_factory=list)

    def transition(self, state: RelationshipState, *, reason: str | None = None) -> None:
        if state == self.state:
            return
        if state not in _ALLOWED_TRANSITIONS[self.state]:
            raise RelationshipError(
                f"invalid relationship transition: {self.state.value} -> {state.value}"
            )
        now = _timestamp(_utc_now())
        previous = self.state.value
        self.state = state
        self.updated_at = now
        event: dict[str, Any] = {
            "event": "relationship.transition",
            "from": previous,
            "to": state.value,
            "at": now,
        }
        if reason:
            event["reason"] = reason
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
            "evidence": list(self.evidence),
        }


def create_capability(
    issuer: str,
    capabilities: list[str] | tuple[str, ...],
    *,
    ttl_seconds: int = DEFAULT_CAPABILITY_TTL_SECONDS,
    now: datetime | None = None,
) -> CapabilityGrant:
    """Create an opaque, single-use relationship establishment capability."""

    if not isinstance(issuer, str) or not issuer:
        raise CapabilityError("issuer is required")
    if not capabilities or not all(isinstance(item, str) and item for item in capabilities):
        raise CapabilityError("at least one non-empty capability is required")
    if ttl_seconds <= 0:
        raise CapabilityError("ttl_seconds must be positive")

    issued = (now or _utc_now()).astimezone(timezone.utc)
    expires = issued + timedelta(seconds=ttl_seconds)
    payload = {
        "protocol": PROTOCOL,
        "issuer": issuer,
        "capabilities": sorted(set(capabilities)),
        "issued_at": _timestamp(issued),
        "expires_at": _timestamp(expires),
        "nonce": _b64e(secrets.token_bytes(24)),
    }
    token = f"{CAPABILITY_PREFIX}.{_b64e(_canonical_json(payload))}.{_b64e(secrets.token_bytes(32))}"
    return CapabilityGrant(token=token, **payload | {"capabilities": tuple(payload["capabilities"])})


def accept_capability(
    token: str,
    acceptor: str,
    *,
    now: datetime | None = None,
    used_capabilities: set[str] | None = None,
) -> Relationship:
    """Consume a capability and create an active relationship."""

    if not isinstance(acceptor, str) or not acceptor:
        raise CapabilityError("acceptor is required")

    grant = CapabilityGrant.from_token(token)
    current = (now or _utc_now()).astimezone(timezone.utc)
    if grant.is_expired(current):
        raise CapabilityError("capability has expired")

    consumed = used_capabilities if used_capabilities is not None else set()
    digest = grant.digest
    if digest in consumed:
        raise CapabilityError("capability has already been consumed")
    if acceptor == grant.issuer:
        raise CapabilityError("acceptor must differ from issuer")

    consumed.add(digest)
    timestamp = _timestamp(current)
    relationship_id = str(uuid.uuid4())
    return Relationship(
        relationship_id=relationship_id,
        initiator=grant.issuer,
        acceptor=acceptor,
        capabilities=grant.capabilities,
        state=RelationshipState.ACTIVE,
        created_at=timestamp,
        updated_at=timestamp,
        capability_digest=digest,
        evidence=[
            {
                "event": "relationship.established",
                "at": timestamp,
                "capability_digest": digest,
            }
        ],
    )
