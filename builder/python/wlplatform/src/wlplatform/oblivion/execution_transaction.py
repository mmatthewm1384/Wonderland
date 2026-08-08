from __future__ import annotations

from copy import deepcopy
from datetime import datetime, timezone
from typing import Any
from uuid import uuid4


class ExecutionTransaction:
    """
    Oblivion execution transaction.

    Canonical persisted representation:

        {
            "type": "oblivion-execution-transaction",
            "schema_version": 1,
            "transaction_id": "txn-...",
            "subject": {...},
            "authorization": {...},
            "method": {...},
            "intent": {...},
            "state": {"status": "..."},
            "result": None,
            "error": None,
        }

    The instance API provides the historical convenience interface while
    the serialized dictionary remains the canonical transaction form.
    """

    TYPE = "oblivion-execution-transaction"
    SCHEMA_VERSION = 1

    PENDING = "PENDING"
    PREPARED = "PREPARED"
    RUNNING = "RUNNING"
    SUCCEEDED = "SUCCEEDED"
    FAILED = "FAILED"
    ROLLED_BACK = "ROLLED_BACK"

    READY = "READY"

    TERMINAL_STATES = {
        SUCCEEDED,
        FAILED,
        ROLLED_BACK,
    }

    TRANSITIONS = {
        PENDING: {
            "prepare": PREPARED,
        },
        PREPARED: {
            "start": RUNNING,
        },
        RUNNING: {
            "succeed": SUCCEEDED,
            "complete": SUCCEEDED,
            "fail": FAILED,
        },
        FAILED: {
            "rollback": ROLLED_BACK,
        },
    }

    OPERATION_ALIASES = {
        "PENDING": "prepare",
        "PREPARE": "prepare",
        "PREPARED": "prepare",
        "READY": "prepare",
        "START": "start",
        "RUNNING": "start",
        "SUCCEED": "succeed",
        "SUCCEEDED": "succeed",
        "COMPLETE": "complete",
        "COMPLETED": "complete",
        "FAIL": "fail",
        "FAILED": "fail",
        "ROLLBACK": "rollback",
        "ROLLED_BACK": "rollback",
    }

    def __init__(
        self,
        intent: dict[str, Any],
        method: str | dict[str, Any] | None,
    ) -> None:
        if not isinstance(intent, dict):
            raise RuntimeError(
                "Execution intent must be an object"
            )

        # Preserve the caller's original intent object by identity.
        self.intent = intent
        self._method_input = method

        self.transaction_id = (
            f"txn-{uuid4().hex}"
        )

        self.started: datetime | None = None
        self.completed: datetime | None = None
        self.rolled_back: datetime | None = None

        self._document = self._build_document(
            intent,
            method,
        )

    # ------------------------------------------------------------------
    # Construction
    # ------------------------------------------------------------------

    @classmethod
    def create(
        cls,
        route: dict[str, Any],
    ) -> dict[str, Any]:
        if not isinstance(route, dict):
            raise RuntimeError(
                "Execution route must be an object"
            )

        authorization = route.get("authorization")

        if not isinstance(authorization, dict):
            raise RuntimeError(
                "Execution route requires authorization"
            )

        if authorization.get("status") != "GRANTED":
            raise RuntimeError(
                "Execution route is not authorized"
            )

        subject = route.get("subject")

        if not isinstance(subject, dict):
            raise RuntimeError(
                "Execution route requires subject"
            )

        intent = route.get("intent")

        if intent is None:
            intent = route.get("execution_intent")

        if intent is None:
            intent = {
                "type": "execution-intent",
                "schema_version": 1,
                "subject": deepcopy(subject),
            }

        if not isinstance(intent, dict):
            raise RuntimeError(
                "Execution route must contain an execution intent"
            )

        method = route.get("method")

        if method is None:
            method = route.get("selected_method")

        if method is None:
            method = route.get("resolved_method")

        if method is None:
            method = {
                "id": "identity.registry",
            }

        transaction = cls(
            intent,
            method,
        )

        transaction._document["subject"] = deepcopy(
            subject
        )

        transaction._document["authorization"] = deepcopy(
            authorization
        )

        transaction._document["route"] = deepcopy(
            route
        )

        transaction.validate(
            transaction.snapshot()
        )

        return transaction.snapshot()

    def _build_document(
        self,
        intent: dict[str, Any],
        method: str | dict[str, Any] | None,
    ) -> dict[str, Any]:
        if isinstance(method, str):
            method_document = {
                "id": method,
            }
        elif isinstance(method, dict):
            method_document = deepcopy(method)
        else:
            method_document = None

        subject = intent.get("subject")

        if not isinstance(subject, dict):
            subject = {}

        return {
            "type": self.TYPE,
            "schema_version": self.SCHEMA_VERSION,
            "transaction_id": self.transaction_id,
            "subject": deepcopy(subject),
            "authorization": {
                "status": "GRANTED",
            },
            "method": method_document,
            "intent": deepcopy(intent),
            "state": {
                "status": self.PENDING,
            },
            "result": None,
            "error": None,
        }

    # ------------------------------------------------------------------
    # Canonical document access
    # ------------------------------------------------------------------

    @property
    def state(self) -> str:
        return self._document["state"]["status"]

    @property
    def error(self) -> dict[str, Any] | None:
        return self._document.get("error")

    @property
    def result(self) -> dict[str, Any] | None:
        return self._document.get("result")

    def snapshot(self) -> dict[str, Any]:
        return deepcopy(self._document)

    def _snapshot(self) -> dict[str, Any]:
        return self.snapshot()

    def _load(
        self,
        transaction: dict[str, Any],
    ) -> None:
        """
        Synchronize instance state from a canonical transaction document.

        IMPORTANT:
        self.intent is intentionally not replaced here. The historical
        API guarantees identity preservation of the original intent object.
        """
        if not isinstance(transaction, dict):
            raise RuntimeError(
                "Transaction must be an object"
            )

        self._document = deepcopy(transaction)

        self.transaction_id = self._document.get(
            "transaction_id",
            self.transaction_id,
        )

    def _set_state(
        self,
        status: str,
    ) -> None:
        self._document["state"] = {
            "status": status,
        }

    # ------------------------------------------------------------------
    # Canonical state helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _status(
        transaction: dict[str, Any],
    ) -> str:
        if not isinstance(transaction, dict):
            raise RuntimeError(
                "Transaction must be an object"
            )

        state = transaction.get("state")

        if isinstance(state, dict):
            status = state.get("status")
        else:
            status = state

        if not isinstance(status, str):
            raise RuntimeError(
                "Transaction state status is required"
            )

        return status

    @classmethod
    def _canonical_operation(
        cls,
        operation: str,
    ) -> str:
        if not isinstance(operation, str):
            raise RuntimeError(
                "Transaction transition must be a string"
            )

        normalized = operation.strip().upper()

        return cls.OPERATION_ALIASES.get(
            normalized,
            normalized.lower(),
        )

    @classmethod
    def _apply_transition(
        cls,
        transaction: dict[str, Any],
        operation: str,
        value: Any = None,
    ) -> dict[str, Any]:
        if not isinstance(transaction, dict):
            raise RuntimeError(
                "Transaction must be an object"
            )

        canonical = cls._canonical_operation(
            operation
        )

        state = cls._status(transaction)

        transitions = cls.TRANSITIONS.get(
            state,
            {},
        )

        next_state = transitions.get(
            canonical
        )

        if next_state is None:
            raise RuntimeError(
                "Illegal transaction transition: "
                f"{state} -> {canonical}"
            )

        if next_state == cls.SUCCEEDED:
            if not isinstance(value, dict):
                raise RuntimeError(
                    "Succeeded transaction requires result object"
                )

            transaction["result"] = deepcopy(value)
            transaction["error"] = None

        elif next_state == cls.FAILED:
            if not isinstance(value, str) or not value.strip():
                raise RuntimeError(
                    "Failed transaction requires error reason"
                )

            transaction["error"] = {
                "reason": value.strip(),
            }
            transaction["result"] = None

        elif next_state == cls.ROLLED_BACK:
            transaction["result"] = None
            transaction["error"] = None

        else:
            transaction["result"] = None
            transaction["error"] = None

        transaction["state"] = {
            "status": next_state,
        }

        cls.validate(transaction)

        return transaction

    # ------------------------------------------------------------------
    # Validation
    # ------------------------------------------------------------------

    @classmethod
    def validate(
        cls,
        transaction: dict[str, Any],
    ) -> dict[str, Any]:
        if not isinstance(transaction, dict):
            raise RuntimeError(
                "Transaction must be an object"
            )

        if transaction.get("type") != cls.TYPE:
            raise RuntimeError(
                "Invalid transaction type"
            )

        if transaction.get(
            "schema_version"
        ) != cls.SCHEMA_VERSION:
            raise RuntimeError(
                "Unsupported transaction schema version"
            )

        if not transaction.get("transaction_id"):
            raise RuntimeError(
                "Transaction requires transaction_id"
            )

        state = transaction.get("state")

        if not isinstance(state, dict):
            raise RuntimeError(
                "Transaction state must be an object"
            )

        status = state.get("status")

        valid_states = {
            cls.PENDING,
            cls.PREPARED,
            cls.RUNNING,
            cls.SUCCEEDED,
            cls.FAILED,
            cls.ROLLED_BACK,
        }

        if status not in valid_states:
            raise RuntimeError(
                f"Invalid transaction state: {status}"
            )

        if not isinstance(
            transaction.get("subject"),
            dict,
        ):
            raise RuntimeError(
                "Transaction subject is required"
            )

        if not isinstance(
            transaction.get("authorization"),
            dict,
        ):
            raise RuntimeError(
                "Transaction authorization is required"
            )

        if not isinstance(
            transaction.get("method"),
            dict,
        ):
            raise RuntimeError(
                "Transaction method is required"
            )

        if "result" not in transaction:
            transaction["result"] = None

        if "error" not in transaction:
            transaction["error"] = None

        result = transaction.get("result")

        if status != cls.SUCCEEDED and result is not None:
            raise RuntimeError(
                "Transaction result cannot exist "
                "outside SUCCEEDED state"
            )

        if status == cls.SUCCEEDED:
            if not isinstance(result, dict):
                raise RuntimeError(
                    "Succeeded transaction requires result object"
                )

        error = transaction.get("error")

        if status == cls.FAILED:
            if not isinstance(error, dict):
                raise RuntimeError(
                    "Failed transaction requires error object"
                )

            if not error.get("reason"):
                raise RuntimeError(
                    "Failed transaction requires error reason"
                )

        if status != cls.FAILED and error is not None:
            raise RuntimeError(
                "Transaction error cannot exist "
                "outside FAILED state"
            )

        return transaction

    # ------------------------------------------------------------------
    # State machine
    # ------------------------------------------------------------------

    def _transition(
        self,
        operation: str,
        value: Any = None,
    ) -> None:
        transaction = self.snapshot()

        transaction = type(self)._apply_transition(
            transaction,
            operation,
            value,
        )

        self._load(transaction)

    def transition(
        self,
        operation: str,
        value: Any = None,
    ) -> "ExecutionTransaction | dict[str, Any]":
        """
        Execute a transaction state transition.

        Supports both APIs:

            transaction.transition("PREPARED")

        and:

            ExecutionTransaction.transition(
                transaction_dict,
                "PREPARED",
            )
        """
        if not isinstance(operation, str):
            raise RuntimeError(
                "Transaction transition must be a string"
            )

        normalized = operation.strip().upper()

        # ------------------------------------------------------------
        # Determine whether this is the canonical serialized API or
        # the normal instance API.
        # ------------------------------------------------------------
        if isinstance(self, dict):
            transaction = self
            cls = ExecutionTransaction
            instance = None
        else:
            instance = self
            cls = type(self)
            transaction = instance.snapshot()

        aliases = getattr(
            cls,
            "OPERATION_ALIASES",
            {},
        )

        canonical = aliases.get(
            normalized,
            normalized,
        )

        state = cls._status(transaction)

        transitions = cls.TRANSITIONS.get(
            state,
            {},
        )

        next_state = transitions.get(
            canonical
        )

        if next_state is None:
            raise RuntimeError(
                "Illegal transaction transition: "
                f"{state} -> {canonical}"
            )

        # ------------------------------------------------------------
        # Validate transition payload before mutating the document.
        # ------------------------------------------------------------
        if next_state == cls.SUCCEEDED:
            if not isinstance(value, dict):
                raise RuntimeError(
                    "Succeeded transaction requires result object"
                )

        elif next_state == cls.FAILED:
            if not isinstance(value, str) or not value.strip():
                raise RuntimeError(
                    "Failed transaction requires error reason"
                )

        # ------------------------------------------------------------
        # Apply canonical state transition.
        # ------------------------------------------------------------
        transaction["state"] = {
            "status": next_state,
        }

        if next_state == cls.SUCCEEDED:
            transaction["result"] = deepcopy(value)
            transaction["error"] = None

        elif next_state == cls.FAILED:
            transaction["error"] = {
                "reason": value.strip(),
            }
            transaction["result"] = None

        elif next_state == cls.ROLLED_BACK:
            transaction["result"] = None
            transaction["error"] = None

        else:
            transaction["result"] = None
            transaction["error"] = None

        cls.validate(transaction)

        # ------------------------------------------------------------
        # Object API: synchronize object from canonical document.
        # ------------------------------------------------------------
        if instance is not None:
            instance._load(transaction)

            result = instance.snapshot()

            # Historical convenience API exposes scalar state.
            result["state"] = next_state

            return result

        # ------------------------------------------------------------
        # Canonical serialized API.
        # ------------------------------------------------------------
        return transaction

    def prepare(
        self,
    ) -> dict[str, Any]:
        if self._method_input is None:
            raise RuntimeError(
                "Execution transaction method is required"
            )

        if isinstance(
            self._method_input,
            str,
        ):
            method_id = self._method_input.strip()

            if not method_id:
                raise RuntimeError(
                    "Execution transaction method is required"
                )

            self._document["method"] = {
                "id": method_id,
            }

        elif isinstance(
            self._method_input,
            dict,
        ):
            self._document["method"] = deepcopy(
                self._method_input
            )

        else:
            raise RuntimeError(
                "Execution transaction method is required"
            )

        self._transition("prepare")

        self.validate(
            self.snapshot()
        )

        return self._legacy_result(
            state=self.READY
        )

    def start(
        self,
    ) -> dict[str, Any]:
        self._transition("start")

        self.started = datetime.now(
            timezone.utc
        )

        return self._legacy_result()

    def complete(
        self,
        result: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        """
        Complete a running transaction successfully.

        The default argument is intentional so illegal initial invocation
        produces RuntimeError rather than Python TypeError.
        """
        if isinstance(self, dict):
            transaction = deepcopy(self)

            state = ExecutionTransaction._status(
                transaction
            )

            if "complete" not in ExecutionTransaction.TRANSITIONS.get(
                state,
                {},
            ):
                raise RuntimeError(
                    "Illegal transaction transition: "
                    f"{state} -> complete"
                )

            if not isinstance(result, dict):
                raise RuntimeError(
                    "Transaction result must be an object"
                )

            return ExecutionTransaction._apply_transition(
                transaction,
                "complete",
                result,
            )

        state = self.state

        if "complete" not in self.TRANSITIONS.get(
            state,
            {},
        ):
            raise RuntimeError(
                "Illegal transaction transition: "
                f"{state} -> complete"
            )

        if not isinstance(result, dict):
            raise RuntimeError(
                "Transaction result must be an object"
            )

        self._transition(
            "complete",
            result,
        )

        self.completed = datetime.now(
            timezone.utc
        )

        return self._legacy_result()

    def succeed(
        self,
        result: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        """
        Mark a RUNNING transaction as successfully completed.

        Supports both:

            transaction.succeed(result)

        and the serialized compatibility form:

            ExecutionTransaction.succeed(transaction)

        The compatibility form permits an omitted result and records an
        empty result object. This preserves the historical state-machine
        API while keeping the canonical persisted representation valid.
        """
        # ------------------------------------------------------------
        # Serialized transaction compatibility API.
        # ------------------------------------------------------------
        if isinstance(self, dict):
            transaction = self
            cls = ExecutionTransaction

            state = cls._status(transaction)

            if "succeed" not in cls.TRANSITIONS.get(
                state,
                {},
            ):
                raise RuntimeError(
                    "Illegal transaction transition: "
                    f"{state} -> succeed"
                )

            if result is None:
                result = {}

            if not isinstance(result, dict):
                raise RuntimeError(
                    "Succeeded transaction requires result object"
                )

            return cls.transition(
                transaction,
                "SUCCEEDED",
                result,
            )

        # ------------------------------------------------------------
        # Normal instance API.
        # ------------------------------------------------------------
        cls = type(self)

        state = cls._status(
            self.snapshot()
        )

        if "succeed" not in cls.TRANSITIONS.get(
            state,
            {},
        ):
            raise RuntimeError(
                "Illegal transaction transition: "
                f"{state} -> succeed"
            )

        if not isinstance(result, dict):
            raise RuntimeError(
                "Succeeded transaction requires result object"
            )

        self._document["result"] = deepcopy(result)

        self._transition(
            "succeed"
        )

        self.completed = datetime.now(
            timezone.utc
        )

        self.validate(
            self.snapshot()
        )

        return self.snapshot()

    def fail(
        self,
        reason: str | None = None,
    ) -> dict[str, Any]:
        """
        Mark a transaction as failed.

        The serialized compatibility API may be invoked directly against
        a freshly-created PENDING transaction. In that case it advances
        through PREPARED and RUNNING before applying failure.

        The canonical transition graph itself remains strict.
        """
        if isinstance(self, dict):
            transaction = deepcopy(self)

            if not isinstance(reason, str) or not reason.strip():
                raise RuntimeError(
                    "Failed transaction requires error reason"
                )

            state = ExecutionTransaction._status(
                transaction
            )

            if state == ExecutionTransaction.PENDING:
                transaction = ExecutionTransaction._apply_transition(
                    transaction,
                    "prepare",
                )

                state = ExecutionTransaction._status(
                    transaction
                )

            if state == ExecutionTransaction.PREPARED:
                transaction = ExecutionTransaction._apply_transition(
                    transaction,
                    "start",
                )

                state = ExecutionTransaction._status(
                    transaction
                )

            if "fail" not in ExecutionTransaction.TRANSITIONS.get(
                state,
                {},
            ):
                raise RuntimeError(
                    "Illegal transaction transition: "
                    f"{state} -> fail"
                )

            return ExecutionTransaction._apply_transition(
                transaction,
                "fail",
                reason,
            )

        state = self.state

        if "fail" not in self.TRANSITIONS.get(
            state,
            {},
        ):
            raise RuntimeError(
                "Illegal transaction transition: "
                f"{state} -> fail"
            )

        if not isinstance(reason, str) or not reason.strip():
            raise RuntimeError(
                "Failed transaction requires error reason"
            )

        self._transition(
            "fail",
            reason,
        )

        return self._legacy_result()

    def rollback(
        self,
    ) -> dict[str, Any]:
        """
        Roll back a failed transaction.

        Supports both object and serialized transaction APIs.
        """
        if isinstance(self, dict):
            transaction = deepcopy(self)

            state = ExecutionTransaction._status(
                transaction
            )

            if "rollback" not in ExecutionTransaction.TRANSITIONS.get(
                state,
                {},
            ):
                raise RuntimeError(
                    "Illegal transaction transition: "
                    f"{state} -> rollback"
                )

            return ExecutionTransaction._apply_transition(
                transaction,
                "rollback",
            )

        state = self.state

        if "rollback" not in self.TRANSITIONS.get(
            state,
            {},
        ):
            raise RuntimeError(
                "Illegal transaction transition: "
                f"{state} -> rollback"
            )

        self._transition(
            "rollback"
        )

        self.rolled_back = datetime.now(
            timezone.utc
        )

        return self._legacy_result()

    # ------------------------------------------------------------------
    # Historical convenience representation
    # ------------------------------------------------------------------

    def _legacy_result(
        self,
        state: str | None = None,
    ) -> dict[str, Any]:
        result = self.snapshot()

        if state is None:
            state = result["state"]["status"]

        result["state"] = state

        if result.get("error") is not None:
            error = result["error"]

            if isinstance(error, dict):
                result["error"] = error.get(
                    "reason"
                )

        return result

    # ------------------------------------------------------------------
    # Mapping compatibility
    # ------------------------------------------------------------------

    def __getitem__(
        self,
        key: str,
    ) -> Any:
        return self._document[key]

    def get(
        self,
        key: str,
        default: Any = None,
    ) -> Any:
        return self._document.get(
            key,
            default,
        )

    def __contains__(
        self,
        key: str,
    ) -> bool:
        return key in self._document

    def keys(self):
        return self._document.keys()

    def items(self):
        return self._document.items()

    def values(self):
        return self._document.values()

    def __repr__(self) -> str:
        return (
            "ExecutionTransaction("
            f"id={self.transaction_id!r}, "
            f"state={self.state!r}"
            ")"
        )
