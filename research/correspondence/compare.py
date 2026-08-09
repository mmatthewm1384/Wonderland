from __future__ import annotations
import math


def rmse(a: list[float], b: list[float]) -> float:
    if len(a) != len(b) or not a:
        raise ValueError("series must be equal-length and non-empty")
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b)) / len(a))


def signature_distance(a: dict, b: dict) -> float:
    pa = a.get("polarity", {}).get("trajectory", [])
    pb = b.get("polarity", {}).get("trajectory", [])
    if not pa or not pb:
        return float("nan")
    n = min(len(pa), len(pb))
    return rmse(pa[:n], pb[:n])
