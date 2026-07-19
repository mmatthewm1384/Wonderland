from dataclasses import dataclass, field


@dataclass
class RealityNode:
    id: str
    category: str
    description: str
    properties: dict = field(default_factory=dict)


@dataclass
class RealityRelation:
    source: str
    target: str
    relationship: str


@dataclass
class RealityModel:
    name: str
    nodes: list
    relations: list
