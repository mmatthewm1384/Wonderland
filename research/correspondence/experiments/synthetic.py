from __future__ import annotations
from dataclasses import dataclass
import math

@dataclass(frozen=True)
class Series:
    name: str
    times: list[float]
    polarity: list[float]


def bistable_series(points: int = 1001, duration: float = 20.0, rate: float = 1.0) -> Series:
    if points < 3 or duration <= 0 or rate <= 0:
        raise ValueError("points >= 3, duration > 0, and rate > 0 are required")
    dt = duration / (points - 1)
    times = [i * dt for i in range(points)]
    # A smooth tanh transition is a deterministic control trajectory.
    center = duration / 2
    polarity = [math.tanh(-rate * (t - center)) for t in times]
    return Series("synthetic-bistable", times, polarity)


def rescale_series(series: Series, time_scale: float, polarity_scale: float = 1.0) -> Series:
    if time_scale <= 0 or polarity_scale <= 0:
        raise ValueError("scales must be > 0")
    return Series(series.name + ":rescaled", [t * time_scale for t in series.times], [p * polarity_scale for p in series.polarity])
