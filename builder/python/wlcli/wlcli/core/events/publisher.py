from __future__ import annotations

from wlcli.core.events.bus import EventBus
from wlcli.core.events.payloads import GraphPayload, StagePayload
from wlcli.core.events.types import EventType


class EventPublisher:
    def __init__(self, bus: EventBus, source: str = "boot-graph"):
        self.bus = bus
        self.source = source

    def graph_started(self, graph: str, stage_count: int) -> None:
        self.bus.emit(
            EventType.GRAPH_STARTED,
            source=self.source,
            payload=GraphPayload(graph=graph, stage_count=stage_count).to_dict(),
        )

    def graph_completed(self, graph: str, duration: float) -> None:
        self.bus.emit(
            EventType.GRAPH_COMPLETED,
            source=self.source,
            payload=GraphPayload(graph=graph, duration=duration).to_dict(),
        )

    def graph_failed(self, graph: str, duration: float) -> None:
        self.bus.emit(
            EventType.GRAPH_FAILED,
            source=self.source,
            severity="ERROR",
            payload=GraphPayload(graph=graph, duration=duration).to_dict(),
        )

    def stage_started(self, graph: str, stage_id: str, title: str) -> None:
        self.bus.emit(
            EventType.STAGE_STARTED,
            source=self.source,
            payload=StagePayload(graph=graph, stage=stage_id, title=title).to_dict(),
        )

    def stage_completed(
        self,
        graph: str,
        *,
        stage_id: str,
        title: str,
        state: str,
        code: int,
        duration: float,
        log: str,
    ) -> None:
        failed = state != "PASS"

        self.bus.emit(
            EventType.STAGE_FAILED if failed else EventType.STAGE_COMPLETED,
            source=self.source,
            severity="ERROR" if failed else "INFO",
            payload=StagePayload(
                graph=graph,
                stage=stage_id,
                title=title,
                state=state,
                code=code,
                duration=duration,
                log=log,
            ).to_dict(),
        )
