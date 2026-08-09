from __future__ import annotations
import math


def normalized_time(times: list[float], transition_index: int, characteristic_tau: float) -> list[float]:
    if characteristic_tau <= 0:
        raise ValueError("characteristic_tau must be > 0")
    if not times or not 0 <= transition_index < len(times):
        raise ValueError("transition_index must identify an element of times")
    t0 = times[transition_index]
    return [(t - t0) / characteristic_tau for t in times]


def normalize_polarity(values: list[float]) -> list[float]:
    if not values:
        return []
    magnitude = max(abs(v) for v in values)
    if magnitude == 0:
        return [0.0 for _ in values]
    return [max(-1.0, min(1.0, v / magnitude)) for v in values]


def transition_time(times: list[float], polarity: list[float], threshold: float = 0.1) -> float:
    if len(times) != len(polarity):
        raise ValueError("times and polarity must have equal length")
    if threshold < 0:
        raise ValueError("threshold must be >= 0")
    for t, p in zip(times, polarity):
        if abs(p) <= threshold:
            return t
    return math.nan
