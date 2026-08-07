from pathlib import Path

from .engine_router import EngineRouter


class ServiceRouter:
    """
    Compatibility adapter used by the legacy dispatcher.
    """

    def __init__(self, root):
        self._router = EngineRouter(Path(root))

    def execute(self, service, action, *args):
        if args:
            raise NotImplementedError(
                f"Legacy positional arguments are not implemented yet: {args!r}"
            )

        return self._router.execute(
            engine=service,
            action=action,
        )
