from __future__ import annotations

from pathlib import Path

from .engines import get_engine


class EngineRouter:

    def __init__(
        self,
        root: Path,
    ):
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


        if hasattr(
            result,
            "to_dict",
        ):
            return result.to_dict()


        raise TypeError(
            "engine result violates contract: "
            f"{type(result)!r}"
        )
