from __future__ import annotations

import math


def clamp01(value: float) -> float:
    return max(0.0, min(1.0, value))


def linear(t: float) -> float:
    return clamp01(t)


def ease_in_out_sine(t: float) -> float:
    t = clamp01(t)
    return -(math.cos(math.pi * t) - 1.0) / 2.0


def ease_out_cubic(t: float) -> float:
    t = clamp01(t)
    return 1.0 - pow(1.0 - t, 3)


def pulse(t: float) -> float:
    t = clamp01(t)
    return math.sin(t * math.pi)
