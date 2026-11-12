from collections.abc import Callable, Mapping
from dataclasses import dataclass
from typing import Any, Protocol


@dataclass(frozen=True)
class AuthorizationSnapshot:
    authorization: Mapping[str, Any]
    revision: str | int


class AuthorizationAuthority(Protocol):
    def get_current_authorization(
        self,
        authorization_id: str,
    ) -> AuthorizationSnapshot | None: ...


class CrystalAuthorizationAuthority:
    """
    Adapter for the authoritative Crystal authorization ledger.

    read_current must perform a fresh authoritative read and return:

        {
            "authorization": { ...canonical authorization fields... },
            "revision": "crystal-record-revision"
        }

    It must return None when the authorization does not exist.

    It must raise on read failure. The adapter never treats a cached
    or unavailable record as valid authorization.
    """

    def __init__(
        self,
        read_current: Callable[[str], Mapping[str, Any] | None],
    ) -> None:
        if not callable(read_current):
            raise TypeError("read_current must be callable.")

        self._read_current = read_current

    def get_current_authorization(
        self,
        authorization_id: str,
    ) -> AuthorizationSnapshot | None:

        if not isinstance(authorization_id, str) or not authorization_id.strip():
            return None

        record = self._read_current(authorization_id)

        if record is None:
            return None

        if not isinstance(record, Mapping):
            raise TypeError("Crystal returned an invalid record.")

        authorization = record.get("authorization")
        revision = record.get("revision")

        if not isinstance(authorization, Mapping):
            raise ValueError("Crystal record has no valid authorization mapping.")

        if (
            not isinstance(revision, (str, int))
            or isinstance(revision, bool)
            or (isinstance(revision, str) and not revision.strip())
        ):
            raise ValueError("Crystal record revision is invalid.")

        return AuthorizationSnapshot(
            authorization=dict(authorization),
            revision=revision,
        )
