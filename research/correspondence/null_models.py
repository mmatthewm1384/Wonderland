from __future__ import annotations
import random


def phase_scramble(values: list[float], seed: int = 0) -> list[float]:
    rng = random.Random(seed)
    result = list(values)
    rng.shuffle(result)
    return result


def permutation_null(values_a, values_b, repeats: int = 1000, seed: int = 0):
    if repeats < 1:
        raise ValueError("repeats must be >= 1")
    rng = random.Random(seed)
    pool = list(values_a) + list(values_b)
    n = len(values_a)
    if not values_a or not values_b:
        raise ValueError("both input series must be non-empty")
    for _ in range(repeats):
        shuffled = list(pool)
        rng.shuffle(shuffled)
        yield shuffled[:n], shuffled[n:]
