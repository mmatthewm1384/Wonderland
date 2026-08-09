from __future__ import annotations
from dataclasses import asdict
import json
from pathlib import Path
from .synthetic import bistable_series
from ..normalize import normalize_polarity, transition_time

SCHEMA = "correspondence-result-v0.1"


def run_synthetic(output: str | Path) -> dict:
    series = bistable_series()
    normalized = normalize_polarity(series.polarity)
    t0 = transition_time(series.times, normalized)
    result = {
        "schema": SCHEMA,
        "experiment": "synthetic-bistable-control",
        "parameters": {"points": len(series.times), "duration": 20.0, "rate": 1.0},
        "transition_time": t0,
        "trajectory": {"time": series.times, "polarity": normalized},
        "provenance": {"generator": "research.correspondence.experiments.synthetic", "deterministic": True},
    }
    path = Path(output)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return result
