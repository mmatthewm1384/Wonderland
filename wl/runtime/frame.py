from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Iterable, Tuple


class Align(str, Enum):
    LEFT = "left"
    CENTER = "center"
    RIGHT = "right"


@dataclass(frozen=True)
class Style:
    role: str = "default"
    bold: bool = False
    dim: bool = False
    inverse: bool = False


@dataclass(frozen=True)
class Position:
    """Compatibility value object for older imports.

    Runtime Phase 2 uses row/col directly. Position remains only as a harmless
    migration value object.
    """

    row: int = 0
    col: int = 0


@dataclass(frozen=True)
class Text:
    text: str
    row: int
    col: int | None = None
    align: Align = Align.LEFT
    style: Style = field(default_factory=Style)
    layer: int = 0


@dataclass(frozen=True)
class Box:
    row: int
    col: int
    width: int
    height: int
    title: str = ""
    style: Style = field(default_factory=lambda: Style(role="box"))
    layer: int = 0

    def __post_init__(self) -> None:
        if self.width < 2:
            raise ValueError("Box width must be >= 2")
        if self.height < 2:
            raise ValueError("Box height must be >= 2")


@dataclass(frozen=True)
class Rule:
    row: int
    col: int = 1
    width: int | None = None
    char: str = "─"
    style: Style = field(default_factory=lambda: Style(role="rule"))
    layer: int = 0

    def __post_init__(self) -> None:
        if not self.char:
            object.__setattr__(self, "char", "─")
        elif len(self.char) > 1:
            object.__setattr__(self, "char", self.char[0])


DrawCommand = Text | Box | Rule


@dataclass(frozen=True)
class Frame:
    commands: Tuple[DrawCommand, ...] = field(default_factory=tuple)

    def __init__(self, commands: Iterable[DrawCommand] | None = None) -> None:
        object.__setattr__(self, "commands", tuple(commands or ()))

    @classmethod
    def empty(cls) -> "Frame":
        return cls(())

    @classmethod
    def from_commands(cls, *commands: DrawCommand | Iterable[DrawCommand]) -> "Frame":
        normalized: list[DrawCommand] = []
        for command in commands:
            if isinstance(command, (list, tuple)):
                normalized.extend(command)
            else:
                normalized.append(command)
        return cls(normalized)

    def add(self, *commands: DrawCommand | Iterable[DrawCommand]) -> "Frame":
        return Frame.from_commands(self.commands, *commands)


__all__ = [
    "Align",
    "Style",
    "Position",
    "Text",
    "Box",
    "Rule",
    "DrawCommand",
    "Frame",
]
