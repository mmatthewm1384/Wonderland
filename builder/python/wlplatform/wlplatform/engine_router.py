from __future__ import annotations

from pathlib import Path
import json

from .engines import get_engine


ENGINE_HANDLERS = {
    "architecture": "architecture",
    "builder": "builder",
    "governance": "governance",
    "mirror": "mirror",
    "academy": "academy",
    "registry": "registry",
}


class EngineRouter:

    def __init__(self, root: Path):
        self.root = Path(root)

    def execute(
        self,
        engine: str,
        action: str,
        *,
        json: bool = False,
    ):

        instance = get_engine(
            engine,
            self.root,
        )

        method = getattr(
            instance,
            action,
            None,
        )

        if method is None:
            return {
                "engine": engine,
                "action": action,
                "status": "UNKNOWN_ACTION",
            }

        result = method()

        if action == "certify":
            instance.write_artifact(result)

        if hasattr(result, "to_dict"):
            return result.to_dict()

        if isinstance(result, dict):
            return result

        raise TypeError(
            f"engine result does not implement to_dict: {type(result)!r}"
        )


    def _result(
        self,
        engine,
        action,
        status,
    ):
        return {
            "engine": engine,
            "action": action,
            "status": status,
        }


    def _architecture(self, action):
        return self._result(
            "architecture",
            action,
            "READY_FOR_IMPLEMENTATION",
        )


    def _builder(self, action):
        return self._result(
            "builder",
            action,
            "READY_FOR_IMPLEMENTATION",
        )


    def _governance(self, action):
        return self._result(
            "governance",
            action,
            "READY_FOR_IMPLEMENTATION",
        )


    def _mirror(self, action):
        return self._result(
            "mirror",
            action,
            "READY_FOR_IMPLEMENTATION",
        )


    def _academy(self, action):
        return self._result(
            "academy",
            action,
            "READY_FOR_IMPLEMENTATION",
        )


    def _registry(self, action):
        from .registry_adapter import verify_registry

        if action in ("verify", "status"):
            result = verify_registry(
                self.context
            )

            return result

        return self._result(
            "registry",
            action,
            "UNSUPPORTED_ACTION",
        )
