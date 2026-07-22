from dataclasses import dataclass, asdict
from datetime import datetime, timezone


@dataclass
class LifecycleSignal:

    source: str

    status: str

    healthy: bool

    metadata: dict


    def export(self):

        return {
            **asdict(self),
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }



@dataclass
class LifecycleSnapshot:

    runtime: LifecycleSignal

    services: LifecycleSignal

    dependencies: LifecycleSignal

    certification: LifecycleSignal


    def export(self):

        return {

            "runtime":
                self.runtime.export(),

            "services":
                self.services.export(),

            "dependencies":
                self.dependencies.export(),

            "certification":
                self.certification.export()
        }
