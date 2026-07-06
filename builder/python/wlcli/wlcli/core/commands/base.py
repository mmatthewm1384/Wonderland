from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from wlcli.output import CommandResult
from wlcli.runtime.context import RuntimeContext


@dataclass(frozen=True)
class CommandSpec:
    name: str
    namespace: str
    description: str


class CommandHandler(Protocol):
    spec: CommandSpec

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        ...
