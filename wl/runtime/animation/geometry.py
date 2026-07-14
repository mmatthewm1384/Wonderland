from __future__ import annotations

import math
from dataclasses import dataclass


@dataclass(frozen=True)
class Point:
    x: float
    y: float


def rotate(point: Point, radians: float) -> Point:
    cos_v = math.cos(radians)
    sin_v = math.sin(radians)

    return Point(
        x=point.x * cos_v - point.y * sin_v,
        y=point.x * sin_v + point.y * cos_v,
    )


def ring_points(radius: float, count: int, *, phase: float = 0.0) -> list[Point]:
    if count <= 0:
        return []

    return [
        Point(
            x=math.cos((math.tau * i / count) + phase) * radius,
            y=math.sin((math.tau * i / count) + phase) * radius,
        )
        for i in range(count)
    ]
