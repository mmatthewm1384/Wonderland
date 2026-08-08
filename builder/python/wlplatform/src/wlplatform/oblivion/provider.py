"""
Oblivion Provider Execution Boundary v1.

Execution ownership:

    ExecutionIntent
          |
          v
    MethodRouter
          |
          v
    ExecutionTransaction
          |
          v
    ProviderExecutor
          |
          v
    Provider

This module does not authorize capabilities and does not select methods.
It executes an already-authorized method route through an explicitly
registered provider.

Providers are dependency-injected. No implicit provider discovery or
external I/O occurs in this layer.
"""

from __future__ import annotations

from copy import deepcopy
from dataclasses import dataclass
from typing import Any, Callable, Protocol


class ProviderExecutionError(RuntimeError):
    """Base error for provider execution failures."""


class ProviderNotFoundError(ProviderExecutionError):
    """Raised when a routed provider has not been registered."""


class ProviderContractError(ProviderExecutionError):
    """Raised when provider input/output violates the contract."""


@dataclass(frozen=True, slots=True)
class ProviderContext:
    """
    Immutable execution context supplied to a provider.

    The provider receives only the already-resolved execution information.
    """

    transaction_id: str
    subject: dict[str, Any]
    authorization: dict[str, Any]
    method: dict[str, Any]
    intent: dict[str, Any]

    def snapshot(self) -> dict[str, Any]:
        return {
            "transaction_id": self.transaction_id,
            "subject": deepcopy(self.subject),
            "authorization": deepcopy(
                self.authorization
            ),
            "method": deepcopy(self.method),
            "intent": deepcopy(self.intent),
        }


@dataclass(frozen=True, slots=True)
class ProviderResult:
    """
    Canonical provider execution result.
    """

    provider: str
    method: str
    data: dict[str, Any]

    def snapshot(self) -> dict[str, Any]:
        return {
            "provider": self.provider,
            "method": self.method,
            "data": deepcopy(self.data),
        }


class ExecutionProvider(Protocol):
    """
    Provider protocol.

    A provider must expose execute(context) and return either a
    ProviderResult or a plain result mapping.
    """

    def execute(
        self,
        context: ProviderContext,
    ) -> ProviderResult | dict[str, Any]:
        ...


class ProviderExecutor:
    """
    Execute a validated Method Route through a registered provider.

    This class owns provider dispatch only.

    It deliberately does not:
      - authorize capabilities
      - route methods
      - mutate transactions
      - discover providers implicitly
      - perform rollback
    """

    TYPE = "oblivion-provider-execution"
    SCHEMA_VERSION = 1

    def __init__(
        self,
        providers: dict[str, ExecutionProvider] | None = None,
    ) -> None:
        self.providers: dict[str, ExecutionProvider] = {}

        if providers:
            for name, provider in providers.items():
                self.register(name, provider)

    def register(
        self,
        name: str,
        provider: ExecutionProvider,
    ) -> None:
        if not isinstance(name, str) or not name.strip():
            raise ProviderContractError(
                "Provider name is required"
            )

        if not hasattr(provider, "execute"):
            raise ProviderContractError(
                "Provider must implement execute()"
            )

        key = name.strip()

        if key in self.providers:
            raise ProviderContractError(
                f"Provider already registered: {key}"
            )

        self.providers[key] = provider

    def execute(
        self,
        transaction: dict[str, Any],
    ) -> dict[str, Any]:
        """
        Execute the method selected by a canonical transaction.

        The transaction must already contain:
          - authorization.status == GRANTED
          - method.id
          - method.provider
          - method.strategy
          - state.status == RUNNING
        """

        self._validate_transaction(transaction)

        method = transaction["method"]
        provider_name = method["provider"]

        provider = self.providers.get(
            provider_name
        )

        if provider is None:
            raise ProviderNotFoundError(
                f"No provider registered: {provider_name}"
            )

        context = ProviderContext(
            transaction_id=transaction[
                "transaction_id"
            ],
            subject=deepcopy(
                transaction["subject"]
            ),
            authorization=deepcopy(
                transaction["authorization"]
            ),
            method=deepcopy(method),
            intent=deepcopy(
                transaction["intent"]
            ),
        )

        raw_result = provider.execute(
            context
        )

        if isinstance(raw_result, ProviderResult):
            result = raw_result.snapshot()
        elif isinstance(raw_result, dict):
            result = deepcopy(raw_result)
        else:
            raise ProviderContractError(
                "Provider must return ProviderResult "
                "or dict"
            )

        if not isinstance(
            result,
            dict,
        ):
            raise ProviderContractError(
                "Provider result must be an object"
            )

        return {
            "type": self.TYPE,
            "schema_version": self.SCHEMA_VERSION,
            "transaction_id": transaction[
                "transaction_id"
            ],
            "provider": provider_name,
            "method": method["id"],
            "result": result,
        }

    @staticmethod
    def _validate_transaction(
        transaction: dict[str, Any],
    ) -> None:
        if not isinstance(
            transaction,
            dict,
        ):
            raise ProviderContractError(
                "Execution transaction must be an object"
            )

        if transaction.get("type") != (
            "oblivion-execution-transaction"
        ):
            raise ProviderContractError(
                "Invalid execution transaction type"
            )

        if transaction.get(
            "schema_version"
        ) != 1:
            raise ProviderContractError(
                "Unsupported execution transaction schema"
            )

        if not transaction.get(
            "transaction_id"
        ):
            raise ProviderContractError(
                "Execution transaction id is required"
            )

        state = transaction.get("state")

        if not isinstance(
            state,
            dict,
        ) or state.get("status") != "RUNNING":
            raise ProviderContractError(
                "Provider execution requires RUNNING transaction"
            )

        authorization = transaction.get(
            "authorization"
        )

        if not isinstance(
            authorization,
            dict,
        ):
            raise ProviderContractError(
                "Execution transaction authorization is required"
            )

        if authorization.get(
            "status"
        ) != "GRANTED":
            raise ProviderContractError(
                "Provider execution requires authorization"
            )

        subject = transaction.get(
            "subject"
        )

        if not isinstance(
            subject,
            dict,
        ):
            raise ProviderContractError(
                "Execution transaction subject is required"
            )

        method = transaction.get(
            "method"
        )

        if not isinstance(
            method,
            dict,
        ):
            raise ProviderContractError(
                "Execution transaction method is required"
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
                raise ProviderContractError(
                    f"Execution method {field} is required"
                )

        intent = transaction.get(
            "intent"
        )

        if not isinstance(
            intent,
            dict,
        ):
            raise ProviderContractError(
                "Execution transaction intent is required"
            )


class RegistryProvider:
    """
    Minimal deterministic registry provider.

    This is intentionally data-backed rather than filesystem/network-backed.
    The actual registry implementation can be injected later without
    changing the ProviderExecutor contract.
    """

    NAME = "registry"

    def __init__(
        self,
        records: dict[str, Any] | None = None,
    ) -> None:
        self.records = deepcopy(
            records or {}
        )

    def execute(
        self,
        context: ProviderContext,
    ) -> ProviderResult:
        capability = context.subject.get(
            "capability"
        )

        if not isinstance(
            capability,
            str,
        ) or not capability:
            raise ProviderContractError(
                "Provider context capability is required"
            )

        return ProviderResult(
            provider=self.NAME,
            method=context.method["id"],
            data={
                "capability": capability,
                "record": deepcopy(
                    self.records.get(
                        capability
                    )
                ),
            },
        )
