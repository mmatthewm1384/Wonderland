"""
Oblivion Execution Executor v1.
"""

from __future__ import annotations

from copy import deepcopy
from typing import Any

from .execution_transaction import ExecutionTransaction
from .provider import ProviderExecutor, RegistryProvider


class ExecutionExecutorError(RuntimeError):
    """Base error for execution orchestration failures."""


class ExecutionExecutor:
    """
    Injectable execution boundary.

    Supports:

        MethodRoute
            -> ExecutionTransaction
            -> ProviderExecutor
            -> completed transaction

    and:

        ExecutionTransaction
            -> ProviderExecutor
            -> execution envelope
    """

    TYPE = "oblivion-execution"
    SCHEMA_VERSION = 1

    ROUTE_TYPE = "oblivion-method-route"
    TRANSACTION_TYPE = "oblivion-execution-transaction"

    PENDING = "PENDING"
    RUNNING = "RUNNING"
    SUCCEEDED = "SUCCEEDED"
    FAILED = "FAILED"

    def __init__(self, provider_executor):
        if provider_executor is None:
            raise ExecutionExecutorError(
                "Provider executor is required"
            )

        if not callable(
            getattr(provider_executor, "execute", None)
        ):
            raise ExecutionExecutorError(
                "Provider executor must provide execute()"
            )

        self.provider_executor = provider_executor

    def run(
        self,
        value: dict[str, Any],
    ) -> dict[str, Any]:
        """Execute a route or transaction."""

        if not isinstance(value, dict):
            raise ExecutionExecutorError(
                "Execution input must be an object"
            )

        input_type = value.get("type")

        if input_type == self.ROUTE_TYPE:
            return self._execute_route(value)

        if input_type == self.TRANSACTION_TYPE:
            return self._execute_transaction(value)

        raise ExecutionExecutorError(
            "Invalid execution input type"
        )

    def execute(
        self,
        value: dict[str, Any],
    ) -> dict[str, Any]:
        """
        Backward-compatible execution entry point.

        MethodRoute input returns the completed transaction.
        ExecutionTransaction input returns the completed transaction.
        """

        result = self.run(value)

        if isinstance(result, dict) and "transaction" in result:
            return deepcopy(result["transaction"])

        return result

    def _execute_route(
        self,
        route: dict[str, Any],
    ) -> dict[str, Any]:
        """
        Compatibility path:

            MethodRoute -> completed transaction
        """

        working_route = deepcopy(route)

        try:
            transaction = ExecutionTransaction.create(
                working_route
            )
        except Exception as exc:
            raise ExecutionExecutorError(
                str(exc)
            ) from exc

        execution = self._execute_transaction(
            transaction
        )

        return deepcopy(
            execution["transaction"]
        )

    def _execute_transaction(
        self,
        transaction: dict[str, Any],
    ) -> dict[str, Any]:
        """Canonical transaction execution path."""

        if not isinstance(transaction, dict):
            raise ExecutionExecutorError(
                "Execution transaction must be an object"
            )

        working = deepcopy(transaction)

        if working.get("type") != self.TRANSACTION_TYPE:
            raise ExecutionExecutorError(
                "Invalid execution transaction type"
            )

        state = working.get("state")

        if not isinstance(state, dict):
            raise ExecutionExecutorError(
                "Execution transaction state is required"
            )

        if state.get("status") != self.PENDING:
            raise ExecutionExecutorError(
                f"Transaction cannot execute from state {state}"
            )

        working["state"] = {
            "status": self.RUNNING
        }

        try:
            provider_execution = (
                self.provider_executor.execute(
                    working
                )
            )
        except Exception:
            working["state"] = {
                "status": self.FAILED
            }
            raise

        if not isinstance(
            provider_execution,
            dict,
        ):
            raise ExecutionExecutorError(
                "Provider execution result must be an object"
            )

        if provider_execution.get(
            "type"
        ) != "oblivion-provider-execution":
            raise ExecutionExecutorError(
                "Invalid provider execution type"
            )

        provider_result = provider_execution.get(
            "result"
        )

        if not isinstance(
            provider_result,
            dict,
        ):
            raise ExecutionExecutorError(
                "Provider execution result record is required"
            )

        working["state"] = {
            "status": self.SUCCEEDED
        }

        # The transaction's canonical result is the provider
        # result record, not the complete provider execution
        # envelope.
        working["result"] = deepcopy(
            provider_result
        )

        working["error"] = None

        return {
            "type": self.TYPE,
            "schema_version": self.SCHEMA_VERSION,
            "transaction": working,
            "provider_execution": deepcopy(
                provider_execution
            ),
        }


class Executor:
    """
    Public compatibility facade.

    Existing lifecycle callers use:

        Executor.execute(transaction)

    The default lifecycle provider registry contains the canonical
    registry provider. Injectable callers should use ExecutionExecutor
    directly with an explicit ProviderExecutor.
    """

    @classmethod
    def execute(
        cls,
        value: dict[str, Any],
    ) -> dict[str, Any]:
        """
        Execute using the canonical default ProviderExecutor.

        The lifecycle currently binds the `registry` provider explicitly.
        No provider discovery or implicit provider selection occurs inside
        ProviderExecutor itself.
        """

        provider_executor = ProviderExecutor(
            {
                "registry": RegistryProvider(
                    records={
                        "identity.read": {
                            "identity": "resolved",
                        },
                    }
                ),
            }
        )

        return ExecutionExecutor(
            provider_executor
        ).run(value)
