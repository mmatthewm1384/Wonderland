"""
Oblivion Execution Executor v1.

Orchestrates the already-authorized execution lifecycle:

    Method Route
        |
        v
    ExecutionTransaction.create()
        |
        v
      PREPARED
        |
        v
       RUNNING
        |
        +------------------+
        |                  |
        v                  v
    ProviderExecutor   provider error
        |                  |
        v                  v
    SUCCEEDED            FAILED

This module coordinates lifecycle boundaries. It does not authorize
capabilities, select methods, or implement provider behavior.
"""

from __future__ import annotations

from copy import deepcopy
from typing import Any

from .execution_transaction import (
    ExecutionTransaction,
)
from .provider import (
    ProviderExecutor,
)


class ExecutionExecutorError(RuntimeError):
    """Base error for execution orchestration failures."""


class ExecutionExecutor:
    """
    Orchestrate one complete Oblivion execution.

    ExecutionTransaction intentionally exposes a canonical serialized
    mapping through create(). The executor therefore uses the class-level
    transaction API rather than assuming an instance object.
    """

    TYPE = "oblivion-execution"
    SCHEMA_VERSION = 1

    def __init__(
        self,
        provider_executor: ProviderExecutor,
    ) -> None:
        if not isinstance(
            provider_executor,
            ProviderExecutor,
        ):
            raise ExecutionExecutorError(
                "provider_executor must be a ProviderExecutor"
            )

        self.provider_executor = provider_executor

    def execute(
        self,
        route: dict[str, Any],
    ) -> dict[str, Any]:
        """
        Execute a routed transaction.

        Lifecycle:

            create
              ↓
            PREPARED
              ↓
            RUNNING
              ↓
            provider
              ↓
            SUCCEEDED / FAILED

        Returns the final canonical transaction on success.

        Provider failures are persisted into the transaction as FAILED
        and then re-raised to the caller.
        """

        self._validate_route(route)

        transaction = ExecutionTransaction.create(
            deepcopy(route)
        )

        transaction = ExecutionTransaction.transition(
            transaction,
            "PREPARED",
        )

        transaction = ExecutionTransaction.transition(
            transaction,
            "RUNNING",
        )

        try:
            execution = (
                self.provider_executor.execute(
                    transaction
                )
            )

            provider_result = execution.get(
                "result"
            )

            if not isinstance(
                provider_result,
                dict,
            ):
                raise ExecutionExecutorError(
                    "Provider execution returned no result object"
                )

            transaction = (
                ExecutionTransaction.transition(
                    transaction,
                    "SUCCEEDED",
                    provider_result,
                )
            )

            return transaction

        except Exception as exc:
            reason = str(exc).strip()

            if not reason:
                reason = (
                    exc.__class__.__name__
                )

            try:
                transaction = (
                    ExecutionTransaction.transition(
                        transaction,
                        "FAILED",
                        reason,
                    )
                )
            except RuntimeError as transition_error:
                raise ExecutionExecutorError(
                    "Execution failed and transaction "
                    "could not enter FAILED state: "
                    f"{transition_error}"
                ) from exc

            raise

    @staticmethod
    def _validate_route(
        route: dict[str, Any],
    ) -> None:
        if not isinstance(
            route,
            dict,
        ):
            raise ExecutionExecutorError(
                "Execution route must be an object"
            )

        if route.get("type") != (
            "oblivion-method-route"
        ):
            raise ExecutionExecutorError(
                "Invalid method route type"
            )

        if route.get(
            "schema_version"
        ) != 1:
            raise ExecutionExecutorError(
                "Unsupported method route schema"
            )

        subject = route.get(
            "subject"
        )

        if not isinstance(
            subject,
            dict,
        ):
            raise ExecutionExecutorError(
                "Execution route subject is required"
            )

        authorization = route.get(
            "authorization"
        )

        if not isinstance(
            authorization,
            dict,
        ):
            raise ExecutionExecutorError(
                "Execution route authorization is required"
            )

        if authorization.get(
            "status"
        ) != "GRANTED":
            raise ExecutionExecutorError(
                "Execution route is not authorized"
            )

        method = route.get(
            "method"
        )

        if not isinstance(
            method,
            dict,
        ):
            raise ExecutionExecutorError(
                "Execution route method is required"
            )

        for field in (
            "id",
            "provider",
            "strategy",
        ):
            value = method.get(field)

            if not isinstance(
                value,
                str,
            ) or not value:
                raise ExecutionExecutorError(
                    f"Execution route method {field} is required"
                )
