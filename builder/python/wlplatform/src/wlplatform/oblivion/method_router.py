"""
Oblivion Method Router v1.

Maps an authorized ExecutionIntent v1 to an available execution
method without executing that method.

Lifecycle:

    CapabilityAttestation v2
            |
            v
    ExecutionIntent v1
            |
            v
    MethodRouter v1
            |
            v
    Method Route
            |
            v
    Execution Transaction

The router is deliberately not an authorization authority.
Authorization remains established by Registry Trust v1.
"""

from __future__ import annotations

from copy import deepcopy

from wlplatform.oblivion.execution_intent import (
    ExecutionIntent,
)


class MethodRouter:
    """
    Resolve a capability to a registered execution method.

    This class performs routing only. It does not execute providers.
    """

    TYPE = "oblivion-method-route"
    SCHEMA_VERSION = 1

    DEFAULT_METHODS = {
        "identity.read": [
            {
                "id": "identity.registry",
                "version": "1",
                "provider": "registry",
                "strategy": "registry-backed",
            }
        ],
        "artifact.read": [
            {
                "id": "artifact.registry",
                "version": "1",
                "provider": "registry",
                "strategy": "registry-backed",
            }
        ],
    }

    def __init__(
        self,
        root=None,
        methods=None,
    ):
        self.root = root

        if methods is None:
            methods = self.DEFAULT_METHODS

        self.methods = deepcopy(methods)

    def route(
        self,
        intent: dict,
    ) -> dict:
        """
        Resolve an ExecutionIntent v1 into a method route.

        Raises RuntimeError if the intent is invalid, unauthorized,
        or no method exists for the requested capability.
        """

        intent = ExecutionIntent.validate_intent(
            intent
        )

        capability = intent["subject"]["capability"]

        candidates = self.methods.get(
            capability,
            [],
        )

        if not candidates:
            raise RuntimeError(
                self._error(
                    "NO_METHOD",
                    intent,
                    "No method registered for capability",
                )
            )

        method = self._select_method(
            candidates
        )

        return {
            "type": self.TYPE,
            "schema_version": self.SCHEMA_VERSION,
            "subject": {
                "package": intent["subject"]["package"],
                "capability": capability,
            },
            "authorization": {
                "status": intent["authorization"]["status"],
                "source": intent["authorization"]["source"],
            },
            "method": deepcopy(method),
            "execution": {
                "status": "PENDING",
            },
        }

    @staticmethod
    def _select_method(
        candidates: list[dict],
    ) -> dict:
        """
        Select the first valid registered method.

        Deterministic selection is intentional for v1.
        """

        for candidate in candidates:

            if not isinstance(candidate, dict):
                continue

            method_id = candidate.get("id")

            provider = candidate.get(
                "provider"
            )

            strategy = candidate.get(
                "strategy"
            )

            if (
                isinstance(method_id, str)
                and method_id
                and isinstance(provider, str)
                and provider
                and isinstance(strategy, str)
                and strategy
            ):
                return candidate

        raise RuntimeError(
            "No valid execution method registered"
        )

    @staticmethod
    def validate_route(
        route: dict,
    ) -> dict:
        """
        Validate a Method Route v1.

        Returns a defensive copy.
        """

        if not isinstance(route, dict):
            raise RuntimeError(
                "Method route must be an object"
            )

        if route.get("type") != (
            MethodRouter.TYPE
        ):
            raise RuntimeError(
                "Invalid method route type"
            )

        if route.get("schema_version") != (
            MethodRouter.SCHEMA_VERSION
        ):
            raise RuntimeError(
                "Unsupported method route schema"
            )

        subject = route.get(
            "subject"
        )

        if not isinstance(
            subject,
            dict,
        ):
            raise RuntimeError(
                "Method route subject missing"
            )

        if not subject.get(
            "package"
        ):
            raise RuntimeError(
                "Method route package missing"
            )

        if not subject.get(
            "capability"
        ):
            raise RuntimeError(
                "Method route capability missing"
            )

        authorization = route.get(
            "authorization"
        )

        if not isinstance(
            authorization,
            dict,
        ):
            raise RuntimeError(
                "Method route authorization missing"
            )

        if authorization.get(
            "status"
        ) != "GRANTED":
            raise RuntimeError(
                "Method route is not authorized"
            )

        if authorization.get(
            "source"
        ) != "registry-trust-v1":
            raise RuntimeError(
                "Method route authorization source invalid"
            )

        method = route.get(
            "method"
        )

        if not isinstance(
            method,
            dict,
        ):
            raise RuntimeError(
                "Method route method missing"
            )

        for field in (
            "id",
            "provider",
            "strategy",
        ):
            value = method.get(
                field
            )

            if not isinstance(
                value,
                str,
            ) or not value:
                raise RuntimeError(
                    f"Method route method {field} missing"
                )

        execution = route.get(
            "execution"
        )

        if not isinstance(
            execution,
            dict,
        ):
            raise RuntimeError(
                "Method route execution state missing"
            )

        if execution.get(
            "status"
        ) != "PENDING":
            raise RuntimeError(
                "Method route must begin in PENDING state"
            )

        return deepcopy(route)

    @staticmethod
    def _error(
        code,
        intent,
        reason,
    ):
        return {
            "status": "ROUTING_FAILED",
            "code": code,
            "package": intent["subject"]["package"],
            "capability": intent["subject"]["capability"],
            "reason": reason,
        }
