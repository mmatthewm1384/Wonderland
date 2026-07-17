from dataclasses import dataclass, asdict


@dataclass
class EngineMetadata:

    name: str
    version: str
    owner: str
    capabilities: list[str]

    def to_dict(self):
        return asdict(self)
