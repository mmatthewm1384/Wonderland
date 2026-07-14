#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import time

from wl.runtime.animation import (
    AnimationEngine,
    FrameClock,
    available_animation_names,
    get_animation,
)
from wl.runtime.terminal import get_terminal_size
from wl.runtime.terminal.screen import Screen
from wl.runtime.widgets.animation import AnimationWidget
from wl.runtime.presentation.frame import compose_screen
from wl.runtime.presentation.frame import compose_screen


def _compose_frame(
    *,
    title: str,
    animation_lines: list[str],
    width: int,
    frame: int,
    total_frames: int,
    fps: float,
) -> str:
    return compose_screen(
        header=[
            "Wonderland Runtime Animation Preview",
            f"{title} | frame {frame + 1}/{total_frames} | {fps:g} FPS",
        ],
        body=animation_lines,
        footer=["Ctrl-C exits cleanly"],
        width=width,
        center_body=True,
    )

def preview(animation_name: str, *, fps: float, duration: float, theme: str) -> int:
    fps = max(float(fps), 1.0)
    duration = max(float(duration), 0.1)

    size = get_terminal_size()
    width = max(40, size.columns)
    height = max(10, size.lines - 6)

    engine = AnimationEngine(
        animation=get_animation(animation_name, theme=theme),
        clock=FrameClock(target_fps=fps),
    )

    widget = AnimationWidget(engine, width=width, height=height)

    total_frames = max(1, int(duration * fps))
    frame_budget = 1.0 / fps

    with Screen(alternate=False, hide_cursor=True) as screen:
        for index in range(total_frames):
            started = time.monotonic()
            progress = index / max(total_frames - 1, 1)

            animation_lines = widget.render(frame=index, progress=progress)

            frame_text = _compose_frame(
                title=animation_name,
                animation_lines=animation_lines,
                width=width,
                frame=index,
                total_frames=total_frames,
                fps=fps,
            )

            screen.render(frame_text, clear=True)

            elapsed = time.monotonic() - started
            time.sleep(max(0.0, frame_budget - elapsed))

    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="wl runtime animation",
        description="Wonderland Runtime animation tools.",
    )
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--preview", choices=available_animation_names())
    parser.add_argument("--fps", type=float, default=30.0)
    parser.add_argument("--duration", type=float, default=5.0)
    parser.add_argument("--theme", default="neon")

    args = parser.parse_args()
    animations = available_animation_names()

    if args.json:
        print(json.dumps({"animations": animations}, indent=2))
        return 0

    if args.preview:
        return preview(args.preview, fps=args.fps, duration=args.duration, theme=args.theme)

    print("Wonderland Runtime Animations\n")
    for name in animations:
        print(f"- {name}")

    print("\nPreview:")
    print("  wl runtime animation --preview vortex")
    print("  wl runtime animation --preview dual-spinner")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
