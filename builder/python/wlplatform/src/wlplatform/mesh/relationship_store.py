"""Durable local operational store for Crystal Mesh relationships.

SQLite is intentionally an operational store here, not the canonical memory
layer. The store owns local relationship state, consumed-capability replay
protection, and lifecycle evidence. Crystal remains the durable memory and
projection layer.
"""

from __future__ import annotations

import json
import sqlite3
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator

from .relationship import Relationship, RelationshipState

SCHEMA_VERSION = 1


class RelationshipStoreError(RuntimeError):
    """Base error for local relationship store failures."""


class RelationshipNotFound(RelationshipStoreError):
    """Raised when a requested relationship does not exist."""


class CapabilityAlreadyConsumed(RelationshipStoreError):
    """Raised when a capability digest has already been consumed."""


class RelationshipStore:
    """SQLite-backed local operational relationship store.

    The connection is opened with WAL mode, foreign-key enforcement, and
    explicit transactions. No private cryptographic key material is stored.
    """

    def __init__(self, path: str | Path):
        self.path = Path(path)
        self._connection: sqlite3.Connection | None = None

    def open(self) -> "RelationshipStore":
        if self._connection is not None:
            return self
        if str(self.path) != ":memory:":
            self.path.parent.mkdir(parents=True, exist_ok=True)
        connection = sqlite3.connect(self.path, isolation_level=None)
        connection.row_factory = sqlite3.Row
        connection.execute("PRAGMA foreign_keys = ON")
        connection.execute("PRAGMA journal_mode = WAL")
        connection.execute("PRAGMA synchronous = FULL")
        connection.execute("PRAGMA busy_timeout = 5000")
        self._connection = connection
        self._migrate()
        return self

    def close(self) -> None:
        if self._connection is not None:
            self._connection.close()
            self._connection = None

    def __enter__(self) -> "RelationshipStore":
        return self.open()

    def __exit__(self, exc_type, exc, tb) -> None:
        self.close()

    @property
    def connection(self) -> sqlite3.Connection:
        if self._connection is None:
            self.open()
        assert self._connection is not None
        return self._connection

    @contextmanager
    def transaction(self) -> Iterator[sqlite3.Connection]:
        connection = self.connection
        connection.execute("BEGIN IMMEDIATE")
        try:
            yield connection
        except Exception:
            connection.execute("ROLLBACK")
            raise
        else:
            connection.execute("COMMIT")

    def _migrate(self) -> None:
        connection = self.connection
        connection.execute(
            """CREATE TABLE IF NOT EXISTS store_meta (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            )"""
        )
        row = connection.execute(
            "SELECT value FROM store_meta WHERE key = 'schema_version'"
        ).fetchone()
        if row is None:
            connection.execute(
                "INSERT INTO store_meta(key, value) VALUES('schema_version', ?)"
                , (str(SCHEMA_VERSION),)
            )
        elif int(row["value"]) != SCHEMA_VERSION:
            raise RelationshipStoreError(
                f"unsupported relationship store schema: {row['value']}"
            )

        connection.executescript(
            """
            CREATE TABLE IF NOT EXISTS relationships (
                relationship_id TEXT PRIMARY KEY,
                initiator TEXT NOT NULL,
                acceptor TEXT NOT NULL,
                capabilities_json TEXT NOT NULL,
                state TEXT NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                capability_digest TEXT NOT NULL UNIQUE,
                issuer_key_fingerprint TEXT NOT NULL,
                evidence_json TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS consumed_capabilities (
                capability_digest TEXT PRIMARY KEY,
                consumed_at TEXT NOT NULL,
                relationship_id TEXT NOT NULL REFERENCES relationships(relationship_id)
                    ON DELETE RESTRICT
            );

            CREATE INDEX IF NOT EXISTS idx_relationships_state
                ON relationships(state);
            CREATE INDEX IF NOT EXISTS idx_relationships_participants
                ON relationships(initiator, acceptor);
            """
        )

    @staticmethod
    def _serialize(relationship: Relationship) -> tuple:
        return (
            relationship.relationship_id,
            relationship.initiator,
            relationship.acceptor,
            json.dumps(list(relationship.capabilities), sort_keys=True),
            relationship.state.value,
            relationship.created_at,
            relationship.updated_at,
            relationship.capability_digest,
            relationship.issuer_key_fingerprint,
            json.dumps(relationship.evidence, sort_keys=True),
        )

    @staticmethod
    def _deserialize(row: sqlite3.Row) -> Relationship:
        return Relationship(
            relationship_id=row["relationship_id"],
            initiator=row["initiator"],
            acceptor=row["acceptor"],
            capabilities=tuple(json.loads(row["capabilities_json"])),
            state=RelationshipState(row["state"]),
            created_at=row["created_at"],
            updated_at=row["updated_at"],
            capability_digest=row["capability_digest"],
            issuer_key_fingerprint=row["issuer_key_fingerprint"],
            evidence=list(json.loads(row["evidence_json"])),
        )

    def put(self, relationship: Relationship) -> None:
        """Insert a relationship exactly once."""
        with self.transaction() as connection:
            try:
                connection.execute(
                    """INSERT INTO relationships(
                        relationship_id, initiator, acceptor, capabilities_json,
                        state, created_at, updated_at, capability_digest,
                        issuer_key_fingerprint, evidence_json
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                    self._serialize(relationship),
                )
            except sqlite3.IntegrityError as exc:
                raise RelationshipStoreError(
                    "relationship or capability digest already exists"
                ) from exc

    def get(self, relationship_id: str) -> Relationship:
        row = self.connection.execute(
            "SELECT * FROM relationships WHERE relationship_id = ?",
            (relationship_id,),
        ).fetchone()
        if row is None:
            raise RelationshipNotFound(relationship_id)
        return self._deserialize(row)

    def list(self, *, state: RelationshipState | None = None) -> list[Relationship]:
        if state is None:
            rows = self.connection.execute(
                "SELECT * FROM relationships ORDER BY created_at, relationship_id"
            ).fetchall()
        else:
            rows = self.connection.execute(
                "SELECT * FROM relationships WHERE state = ? ORDER BY created_at, relationship_id",
                (state.value,),
            ).fetchall()
        return [self._deserialize(row) for row in rows]

    def transition(
        self,
        relationship_id: str,
        state: RelationshipState,
        *,
        reason: str | None = None,
    ) -> Relationship:
        """Apply the domain state machine and persist its evidence atomically."""
        with self.transaction():
            relationship = self.get(relationship_id)
            relationship.transition(state, reason=reason)
            self.connection.execute(
                """UPDATE relationships SET
                    state = ?, updated_at = ?, evidence_json = ?
                   WHERE relationship_id = ?""",
                (
                    relationship.state.value,
                    relationship.updated_at,
                    json.dumps(relationship.evidence, sort_keys=True),
                    relationship.relationship_id,
                ),
            )
        return relationship

    def consume_capability(self, relationship: Relationship, consumed_at: str) -> None:
        """Atomically record a capability as consumed for a stored relationship."""
        with self.transaction() as connection:
            try:
                connection.execute(
                    """INSERT INTO consumed_capabilities(
                        capability_digest, consumed_at, relationship_id
                    ) VALUES (?, ?, ?)""",
                    (relationship.capability_digest, consumed_at, relationship.relationship_id),
                )
            except sqlite3.IntegrityError as exc:
                raise CapabilityAlreadyConsumed(relationship.capability_digest) from exc

    def is_capability_consumed(self, capability_digest: str) -> bool:
        row = self.connection.execute(
            "SELECT 1 FROM consumed_capabilities WHERE capability_digest = ?",
            (capability_digest,),
        ).fetchone()
        return row is not None

    def establish(self, relationship: Relationship, consumed_at: str) -> None:
        """Persist a newly established relationship and consume its capability atomically."""
        with self.transaction() as connection:
            try:
                connection.execute(
                    """INSERT INTO relationships(
                        relationship_id, initiator, acceptor, capabilities_json,
                        state, created_at, updated_at, capability_digest,
                        issuer_key_fingerprint, evidence_json
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                    self._serialize(relationship),
                )
                connection.execute(
                    """INSERT INTO consumed_capabilities(
                        capability_digest, consumed_at, relationship_id
                    ) VALUES (?, ?, ?)""",
                    (relationship.capability_digest, consumed_at, relationship.relationship_id),
                )
            except sqlite3.IntegrityError as exc:
                raise CapabilityAlreadyConsumed(relationship.capability_digest) from exc

    def count(self) -> int:
        return int(self.connection.execute("SELECT COUNT(*) FROM relationships").fetchone()[0])

    def integrity_check(self) -> str:
        return str(self.connection.execute("PRAGMA integrity_check").fetchone()[0])
