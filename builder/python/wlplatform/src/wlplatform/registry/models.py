from dataclasses import dataclass, field


@dataclass(slots=True)
class RegistryIssue:

    level: str

    message: str

    details: dict = field(default_factory=dict)
