from __future__ import annotations

from dataclasses import dataclass, field
from typing import Protocol


class RenderableScene(Protocol):
    def setup(self) -> None:
        ...

    def render(self) -> str:
        ...

    def teardown(self) -> None:
        ...


@dataclass
class Scene:
    """
    Base class for Wonderland Runtime scenes.
    """

    name: str = field(default="scene", init=False)

    def setup(self) -> None:
        """Prepare the scene before rendering begins."""

    def render(self) -> str:
        """Render the current scene frame."""
        raise NotImplementedError(f"{self.__class__.__name__}.render() is not implemented")

    def teardown(self) -> None:
        """Release scene resources after rendering finishes."""
