from __future__ import annotations

from typing import Any

from wlcli.core.events.types import EventType


KNOWN_EVENT_TYPES = {
    EventType.GRAPH_STARTED,
    EventType.GRAPH_COMPLETED,
    EventType.GRAPH_FAILED,
    EventType.STAGE_STARTED,
    EventType.STAGE_COMPLETED,
    EventType.STAGE_FAILED,
    EventType.RUNTIME_STARTED,
    EventType.RUNTIME_STOPPED,
    EventType.RUNTIME_FAILED,
}


REQUIRED_PAYLOAD_KEYS = {
    EventType.GRAPH_STARTED: {"graph", "stage_count"},
    EventType.GRAPH_COMPLETED: {"graph", "duration"},
    EventType.GRAPH_FAILED: {"graph", "duration"},
    EventType.STAGE_STARTED: {"graph", "stage", "title"},
    EventType.STAGE_COMPLETED: {"graph", "stage", "title", "state", "code", "duration", "log"},
    EventType.STAGE_FAILED: {"graph", "stage", "title", "state", "code", "duration", "log"},
}


def validate_event_shape(event_type: str, payload: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    if event_type not in KNOWN_EVENT_TYPES:
        errors.append(f"unknown event type: {event_type}")

    required = REQUIRED_PAYLOAD_KEYS.get(event_type, set())
    missing = sorted(required - set(payload.keys()))

    for key in missing:
        errors.append(f"missing payload key for {event_type}: {key}")

    return errors
