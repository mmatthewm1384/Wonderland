"""Immutable governed search execution for SOVEREIGN-001 v0.2."""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from types import MappingProxyType
from typing import Any, Mapping

from .search_state import (
    ExecutionState,
    ResultState,
    SearchState,
    SearchStateError,
)


class SearchExecutionError(ValueError):
    """Raised when a search execution violates its contract."""


def _freeze(value: Any) -> Any:
    """Recursively detach and freeze execution data."""
    if isinstance(value, Mapping):
        return MappingProxyType(
            {key: _freeze(item) for key, item in value.items()}
        )
    if isinstance(value, (list, tuple)):
        return tuple(_freeze(item) for item in value)
    return value


def _plain(value: Any) -> Any:
    """Convert frozen execution data to JSON-compatible plain data."""
    if isinstance(value, Mapping):
        return {key: _plain(item) for key, item in value.items()}
    if isinstance(value, (list, tuple)):
        return [_plain(item) for item in value]
    return value


def _require_string(value: Any, field: str) -> None:
    if not isinstance(value, str) or not value:
        raise SearchExecutionError(f"{field} must be a non-empty string")


def _require_mapping(value: Any, field: str) -> None:
    if not isinstance(value, Mapping):
        raise SearchExecutionError(f"{field} must be a mapping")


@dataclass(frozen=True)
class SearchExecution:
    """Immutable record of one execution of a SearchDefinition.

    Execution identity describes the observed attempt, while search_id
    identifies the immutable declarative search definition being executed.
    This object records execution and observations; it does not establish
    historical truth or a determination.
    """

    execution_id: str
    search_id: str
    performed_at: str
    performed_by: str
    method: str
    result: SearchState
    tool: str | None = None
    tool_version: str | None = None
    limitations: tuple[Any, ...] = ()
    observations: tuple[Any, ...] = ()
    evidence: tuple[Any, ...] = ()

    def __post_init__(self) -> None:
        _require_string(self.execution_id, "execution_id")
        _require_string(self.search_id, "search_id")
        _require_string(self.performed_at, "performed_at")
        _require_string(self.performed_by, "performed_by")
        _require_string(self.method, "method")

        if not isinstance(self.result, SearchState):
            raise SearchExecutionError("result must be a SearchState")

        if self.tool is not None:
            _require_string(self.tool, "tool")
        if self.tool_version is not None:
            _require_string(self.tool_version, "tool_version")

        for field, value in (
            ("limitations", self.limitations),
            ("observations", self.observations),
            ("evidence", self.evidence),
        ):
            if not isinstance(value, (list, tuple)):
                raise SearchExecutionError(f"{field} must be a list or tuple")

        if self.result.search_id != self.search_id:
            raise SearchExecutionError(
                "result.search_id must match execution search_id"
            )

        try:
            self.result.validate()
        except SearchStateError as exc:
            raise SearchExecutionError(str(exc)) from exc

        object.__setattr__(self, "limitations", _freeze(self.limitations))
        object.__setattr__(self, "observations", _freeze(self.observations))
        object.__setattr__(self, "evidence", _freeze(self.evidence))

        self.validate_identity()

    @classmethod
    def create(
        cls,
        *,
        search_id: str,
        performed_at: str,
        performed_by: str,
        method: str,
        result: SearchState,
        tool: str | None = None,
        tool_version: str | None = None,
        limitations: list[Any] | tuple[Any, ...] = (),
        observations: list[Any] | tuple[Any, ...] = (),
        evidence: list[Any] | tuple[Any, ...] = (),
    ) -> "SearchExecution":
        """Create an execution with a deterministic execution identity."""
        payload = _plain(
            {
                "search_id": search_id,
                "performed_at": performed_at,
                "performed_by": performed_by,
                "method": method,
                "result": result.to_dict(),
                "tool": tool,
                "tool_version": tool_version,
                "limitations": limitations,
                "observations": observations,
                "evidence": evidence,
            }
        )
        encoded = json.dumps(
            payload,
            sort_keys=True,
            separators=(",", ":"),
            ensure_ascii=False,
        ).encode("utf-8")
        execution_id = hashlib.sha256(encoded).hexdigest()

        return cls(
            execution_id=execution_id,
            search_id=search_id,
            performed_at=performed_at,
            performed_by=performed_by,
            method=method,
            result=result,
            tool=tool,
            tool_version=tool_version,
            limitations=limitations,
            observations=observations,
            evidence=evidence,
        )

    def canonical_identity(self) -> str:
        """Return the deterministic identity of this execution."""
        payload = _plain(
            {
                "search_id": self.search_id,
                "performed_at": self.performed_at,
                "performed_by": self.performed_by,
                "method": self.method,
                "result": self.result.to_dict(),
                "tool": self.tool,
                "tool_version": self.tool_version,
                "limitations": self.limitations,
                "observations": self.observations,
                "evidence": self.evidence,
            }
        )
        encoded = json.dumps(
            payload,
            sort_keys=True,
            separators=(",", ":"),
            ensure_ascii=False,
        ).encode("utf-8")
        return hashlib.sha256(encoded).hexdigest()

    def validate_identity(self) -> None:
        """Require execution_id to match its canonical identity."""
        if self.execution_id != self.canonical_identity():
            raise SearchExecutionError(
                "execution_id does not match canonical execution identity"
            )

    def to_dict(self) -> dict[str, Any]:
        """Return a detached JSON-compatible execution representation."""
        return {
            "execution_id": self.execution_id,
            "search_id": self.search_id,
            "performed_at": self.performed_at,
            "performed_by": self.performed_by,
            "method": self.method,
            "result": self.result.to_dict(),
            "tool": self.tool,
            "tool_version": self.tool_version,
            "limitations": _plain(self.limitations),
            "observations": _plain(self.observations),
            "evidence": _plain(self.evidence),
        }
