from dataclasses import dataclass, field


@dataclass
class EngineNode:

    name: str

    depends_on: list[str] = field(
        default_factory=list
    )
