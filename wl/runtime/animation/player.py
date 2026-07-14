from __future__ import annotations

import time
from typing import Callable

from wl.runtime.terminal.screen import Screen


def play_animation(
    frame_fn: Callable[[int, float], str],
    *,
    fps: int = 30,
    duration: float = 5.0,
    alternate: bool = True,
) -> None:
    if fps <= 0:
        raise ValueError("fps must be greater than 0")

    if duration <= 0:
        raise ValueError("duration must be greater than 0")

    frame_budget = 1.0 / fps
    started = time.monotonic()
    frame = 0

    with Screen(alternate=alternate, hide_cursor=True) as screen:
        while True:
            now = time.monotonic()
            elapsed = now - started

            if elapsed >= duration:
                break

            rendered = frame_fn(frame, elapsed)
            screen.render(rendered, clear=True)

            frame += 1
            spent = time.monotonic() - now
            time.sleep(max(0.0, frame_budget - spent))
