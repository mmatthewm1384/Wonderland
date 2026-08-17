"""Cryptographically signed Crystal Mesh capabilities."""

from __future__ import annotations

import base64
import hashlib
import json
import secrets
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Any

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey, Ed25519PublicKey

PROTOCOL = "mesh.capability/1.0"
PREFIX = "wmc1"
DEFAULT_TTL_SECONDS = 15 * 60


def _b64e(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")


def _b64d(value: str) -> bytes:
    try:
        return base64.urlsafe_b64decode(value + "=" * (-len(value) % 4))
    except Exception as exc:
        raise CapabilityFormatError("invalid base64url") from exc


def _canonical(value: dict[str, Any]) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":")).encode("utf-8")


def _timestamp(value: datetime) -> str:
    return value.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def _parse_timestamp(value: str) -> datetime:
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00")).astimezone(timezone.utc)
    except (TypeError, ValueError) as exc:
        raise CapabilityFormatError("invalid timestamp") from exc


class CapabilityFormatError(ValueError):
    """Capability encoding or semantic validation failure."""


class CapabilitySignatureError(CapabilityFormatError):
    """Capability signature verification failure."""


@dataclass(frozen=True)
class SignedCapability:
    protocol: str
    issuer: str
    public_key: str
    capabilities: tuple[str, ...]
    issued_at: str
    expires_at: str
    nonce: str
    token: str

    @property
    def digest(self) -> str:
        return hashlib.sha256(self.token.encode("utf-8")).hexdigest()

    @property
    def key_fingerprint(self) -> str:
        return hashlib.sha256(_b64d(self.public_key)).hexdigest()

    def is_expired(self, now: datetime | None = None) -> bool:
        return (now or datetime.now(timezone.utc)) >= _parse_timestamp(self.expires_at)

    def to_dict(self) -> dict[str, Any]:
        return {
            "protocol": self.protocol,
            "issuer": self.issuer,
            "public_key": self.public_key,
            "capabilities": list(self.capabilities),
            "issued_at": self.issued_at,
            "expires_at": self.expires_at,
            "nonce": self.nonce,
        }

    @classmethod
    def parse(cls, token: str) -> "SignedCapability":
        parts = token.split(".")
        if len(parts) != 3 or parts[0] != PREFIX:
            raise CapabilityFormatError("invalid capability envelope")
        payload = _b64d(parts[1])
        signature = _b64d(parts[2])
        try:
            data = json.loads(payload.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise CapabilityFormatError("invalid capability payload") from exc
        required = {"protocol", "issuer", "public_key", "capabilities", "issued_at", "expires_at", "nonce"}
        if set(data) != required or data["protocol"] != PROTOCOL:
            raise CapabilityFormatError("invalid capability fields")
        if not isinstance(data["issuer"], str) or not data["issuer"]:
            raise CapabilityFormatError("issuer is required")
        if not isinstance(data["capabilities"], list) or not data["capabilities"] or not all(
            isinstance(x, str) and x for x in data["capabilities"]
        ):
            raise CapabilityFormatError("capabilities must be non-empty strings")
        if len(_b64d(data["public_key"])) != 32 or len(signature) != 64:
            raise CapabilityFormatError("invalid Ed25519 key or signature length")
        if not isinstance(data["nonce"], str) or not data["nonce"]:
            raise CapabilityFormatError("nonce is required")
        _parse_timestamp(data["issued_at"])
        _parse_timestamp(data["expires_at"])
        return cls(
            protocol=data["protocol"], issuer=data["issuer"], public_key=data["public_key"],
            capabilities=tuple(data["capabilities"]), issued_at=data["issued_at"],
            expires_at=data["expires_at"], nonce=data["nonce"], token=token,
        )

    def verify(self, *, now: datetime | None = None) -> None:
        parts = self.token.split(".")
        if len(parts) != 3:
            raise CapabilitySignatureError("invalid capability envelope")
        payload = _b64d(parts[1])
        signature = _b64d(parts[2])
        try:
            Ed25519PublicKey.from_public_bytes(_b64d(self.public_key)).verify(signature, payload)
        except (InvalidSignature, ValueError) as exc:
            raise CapabilitySignatureError("capability signature is invalid") from exc
        if self.is_expired(now):
            raise CapabilitySignatureError("capability has expired")


def generate_keypair() -> tuple[Ed25519PrivateKey, Ed25519PublicKey]:
    private = Ed25519PrivateKey.generate()
    return private, private.public_key()


def create_signed_capability(
    issuer: str,
    capabilities: list[str] | tuple[str, ...],
    private_key: Ed25519PrivateKey,
    *,
    ttl_seconds: int = DEFAULT_TTL_SECONDS,
    now: datetime | None = None,
) -> SignedCapability:
    if not issuer:
        raise CapabilityFormatError("issuer is required")
    if not capabilities or not all(isinstance(x, str) and x for x in capabilities):
        raise CapabilityFormatError("at least one capability is required")
    if ttl_seconds <= 0:
        raise CapabilityFormatError("ttl_seconds must be positive")
    issued = (now or datetime.now(timezone.utc)).astimezone(timezone.utc)
    expires = issued + timedelta(seconds=ttl_seconds)
    public_key = private_key.public_key().public_bytes_raw()
    payload = {
        "protocol": PROTOCOL,
        "issuer": issuer,
        "public_key": _b64e(public_key),
        "capabilities": sorted(set(capabilities)),
        "issued_at": _timestamp(issued),
        "expires_at": _timestamp(expires),
        "nonce": _b64e(secrets.token_bytes(24)),
    }
    encoded = _b64e(_canonical(payload))
    signature = private_key.sign(encoded.encode("ascii"))
    token = f"{PREFIX}.{encoded}.{_b64e(signature)}"
    result = SignedCapability.parse(token)
    result.verify(now=issued)
    return result
