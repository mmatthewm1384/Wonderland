from __future__ import annotations

import time
from dataclasses import dataclass, field
from typing import Callable


@dataclass
class ScheduledTask:
    name: str
    interval: float
    callback: Callable[[], None]
    last_run: float = field(default=0.0)
    runs: int = field(default=0)
    failures: int = field(default=0)
    last_error: str | None = field(default=None)

    def due(self, now: float | None = None) -> bool:
        now = now or time.time()
        return now - self.last_run >= self.interval

    def run(self) -> None:
        self.last_run = time.time()
        try:
            self.callback()
            self.runs += 1
            self.last_error = None
        except Exception as e:
            self.failures += 1
            self.last_error = str(e)


class Scheduler:
    def __init__(self):
        self.tasks: list[ScheduledTask] = []

    def add(self, name: str, interval: float, callback: Callable[[], None]) -> None:
        self.tasks.append(ScheduledTask(name=name, interval=interval, callback=callback))

    def tick(self) -> None:
        now = time.time()
        for task in self.tasks:
            if task.due(now):
                task.run()

    def status(self) -> dict:
        return {
            "tasks": [
                {
                    "name": t.name,
                    "interval": t.interval,
                    "last_run": t.last_run,
                    "runs": t.runs,
                    "failures": t.failures,
                    "last_error": t.last_error,
                }
                for t in self.tasks
            ]
        }
