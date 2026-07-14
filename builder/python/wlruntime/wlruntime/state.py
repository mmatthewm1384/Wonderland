from __future__ import annotations

import fcntl
import json
import os
import tempfile
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterator

from .errors import StateError


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


class RuntimeStateStore:
    SCHEMA_VERSION = 1

    def __init__(self, state_path: Path):
        self.state_path = state_path.resolve()
        self.lock_path = self.state_path.with_suffix(
            self.state_path.suffix + ".lock"
        )
        self.state_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

    @contextmanager
    def lock(self) -> Iterator[None]:
        try:
            with self.lock_path.open("a+", encoding="utf-8") as stream:
                fcntl.flock(stream.fileno(), fcntl.LOCK_EX)

                try:
                    yield
                finally:
                    fcntl.flock(stream.fileno(), fcntl.LOCK_UN)
        except OSError as exc:
            raise StateError(
                f"cannot lock runtime state: {exc}"
            ) from exc

    def default_state(self) -> dict[str, Any]:
        return {
            "schema_version": self.SCHEMA_VERSION,
            "status": "stopped",
            "operation": None,
            "operation_id": None,
            "registry_digest": None,
            "started_engines": [],
            "engine_results": {},
            "rollback": {
                "attempted": False,
                "completed": False,
                "results": [],
            },
            "lifecycle": {
                "last_transition": None,
                "sleep_timestamp": None,
            },
            "last_error": None,
            "updated_at": utc_now(),
        }

    def read(self) -> dict[str, Any]:
        if not self.state_path.exists():
            return self.default_state()

        try:
            state = json.loads(
                self.state_path.read_text(encoding="utf-8")
            )
        except (OSError, json.JSONDecodeError) as exc:
            raise StateError(
                f"cannot read runtime state: {exc}"
            ) from exc

        if not isinstance(state, dict):
            raise StateError(
                "runtime state root must be an object"
            )

        if state.get("schema_version") != self.SCHEMA_VERSION:
            raise StateError(
                "unsupported runtime state schema version"
            )

        return state

    def write(self, state: dict[str, Any]) -> None:
        state = dict(state)
        state["schema_version"] = self.SCHEMA_VERSION
        state["updated_at"] = utc_now()

        payload = json.dumps(
            state,
            indent=2,
            sort_keys=True,
        ) + "\n"

        try:
            fd, temporary_path = tempfile.mkstemp(
                prefix=f".{self.state_path.name}.",
                suffix=".tmp",
                dir=self.state_path.parent,
                text=True,
            )

            try:
                with os.fdopen(fd, "w", encoding="utf-8") as stream:
                    stream.write(payload)
                    stream.flush()
                    os.fsync(stream.fileno())

                os.replace(
                    temporary_path,
                    self.state_path,
                )
            finally:
                if os.path.exists(temporary_path):
                    os.unlink(temporary_path)

        except OSError as exc:
            raise StateError(
                f"cannot write runtime state: {exc}"
            ) from exc
