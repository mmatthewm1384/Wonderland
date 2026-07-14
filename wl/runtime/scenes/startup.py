#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import signal
import sys
import time
from dataclasses import dataclass, field

from wl.runtime.animation import AnimationEngine, FrameClock, available_animation_names, get_animation
from wl.runtime.context import RuntimeContext
from wl.runtime.full_start import run_full_start
from wl.runtime.diagnostics.checks import as_status, failed_required, run_checks
from wl.runtime.presentation.colors import RESET, fg
from wl.runtime.presentation.layout import center
from wl.runtime.presentation.layouts import Layout
from wl.runtime.terminal import CLEAR, Screen, get_terminal_size
from wl.runtime.presentation.widgets import render_widgets
from wl.runtime.scenes.base import Scene
from wl.runtime.state.status import write_startup_status
from wl.runtime.themes import THEMES, get_theme
from wl.runtime.widgets import FooterWidget, HeaderWidget, ProgressWidget, SpinnerWidget, StatusListWidget


@dataclass(frozen=True)
class Stage:
    name: str
    threshold: int


STAGES = [
    Stage("Runtime", 10),
    Stage("Vault", 25),
    Stage("Registry", 40),
    Stage("Controller", 55),
    Stage("Services", 70),
    Stage("Scheduler", 85),
    Stage("Matrix", 95),
]


def startup_widgets(
    *,
    width: int,
    title: str,
    subtitle: str | None,
    spinner: list[str],
    progress: float,
    checks: list[tuple[str, str]],
    footer_text: str,
) -> list[str]:
    widgets = [
        HeaderWidget(title, subtitle),
        SpinnerWidget(spinner),
        center(f"{fg(201)}Initializing Wonderland Runtime...{RESET}"),
        StatusListWidget(checks),
        ProgressWidget(progress),
        FooterWidget(footer_text),
    ]

    rendered: list[str] = []
    for widget in widgets:
        if isinstance(widget, str):
            rendered.append(widget)
        else:
            rendered.extend(render_widgets([widget], width))
        rendered.append("")

    return rendered


def stage_statuses(progress: int) -> list[tuple[str, str]]:
    return [
        (stage.name, "pass" if progress >= stage.threshold else "pending")
        for stage in STAGES
    ]


def frame(
    i: int,
    progress: int,
    elapsed_ms: int,
    *,
    title: str,
    subtitle: str,
    theme: str,
    animation: str,
    spinner: list[str] | None = None,
) -> str:
    width = get_terminal_size().columns

    lines = [
        CLEAR,
        "",
        *startup_widgets(
            width=width,
            title=title,
            subtitle=subtitle,
            spinner=spinner or [],
            progress=progress / 100,
            checks=stage_statuses(progress),
            footer_text=f"{elapsed_ms} ms",
        ),
    ]

    return "\n".join(lines)


def ready(elapsed_ms: int, *, title: str, subtitle: str) -> str:
    width = get_terminal_size().columns

    lines = [
        CLEAR,
        "",
        *render_widgets(
            [
                HeaderWidget(title, subtitle),
                StatusListWidget([(stage.name, "pass") for stage in STAGES]),
                center(f"{fg(82)}WONDERLAND RUNTIME READY{RESET}"),
                center(f"{fg(244)}Your terminal. Your world.{RESET}"),
                FooterWidget(f"{elapsed_ms} ms"),
            ],
            width,
        ),
        "",
    ]

    return "\n".join(lines)



@dataclass
class StartupScene(Scene):
    context: RuntimeContext
    started: float
    engine: AnimationEngine

    name: str = field(default="startup", init=False)

    def render_frame(self, i: int) -> str:
        progress = int(i * 100 / self.context.duration)
        elapsed_ms = int((time.perf_counter() - self.started) * 1000)
        width = get_terminal_size().columns
        animation_lines = self.engine.frame(
            i,
            width=width,
            progress=progress / 100,
        )

        return frame(
            i,
            progress,
            elapsed_ms,
            title=self.context.title,
            subtitle=self.context.subtitle,
            theme=self.context.theme_name,
            animation=self.context.animation_name,
            spinner=animation_lines,
        )

    def render_ready(self) -> str:
        elapsed_ms = int((time.perf_counter() - self.started) * 1000)
        return ready(elapsed_ms, title=self.context.title, subtitle=self.context.subtitle)

    def render(self) -> str:
        return self.render_ready()

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="wl start",
        description="Start the Wonderland runtime startup sequence.",
    )
    parser.add_argument("--fast", action="store_true", help="Use a shorter startup animation.")
    parser.add_argument("--no-animation", action="store_true", help="Print final startup status without animation.")
    parser.add_argument("--visual-only", action="store_true", help="Run animation without failing on runtime check errors.")
    parser.add_argument("--full", action="store_true", help="Start full Wonderland local runtime services.")
    parser.add_argument("--frames", type=int, default=int(os.environ.get("WL_START_FRAMES", "180")))
    parser.add_argument("--hold", type=float, default=float(os.environ.get("WL_START_HOLD", "1.2")))
    parser.add_argument("--frame-delay", type=float, default=float(os.environ.get("WL_START_FRAME_DELAY", "0.025")))
    parser.add_argument("--theme", choices=sorted(THEMES), default=os.environ.get("WL_START_THEME", "neon"))
    parser.add_argument("--animation", choices=available_animation_names(), default=os.environ.get("WL_START_ANIMATION", "dual-spinner"))
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    duration = 60 if args.fast else args.frames
    hold = args.hold
    fps_delay = args.frame_delay

    theme = get_theme(args.theme)
    title = theme["title"]
    subtitle = theme["subtitle"]

    duration = max(duration, 1)
    hold = max(hold, 0)
    fps_delay = max(fps_delay, 0)

    terminal = Screen()

    def stop(*_: object) -> None:
        terminal.exit()
        raise SystemExit(130)

    signal.signal(signal.SIGINT, stop)
    signal.signal(signal.SIGTERM, stop)

    checks = run_checks()
    full_results = run_full_start() if args.full else []
    has_required_failure = failed_required(checks)
    started = time.perf_counter()

    context = RuntimeContext(
        title=title,
        subtitle=subtitle,
        theme_name=args.theme,
        animation_name=args.animation,
        mode="fast" if args.fast else "normal",
        duration=duration,
        hold=hold,
        frame_delay=fps_delay,
        visual_only=args.visual_only,
    )

    scene = StartupScene(
        context=context,
        started=started,
        engine=AnimationEngine(
            animation=get_animation(args.animation, theme=args.theme),
            clock=FrameClock(target_fps=1 / fps_delay if fps_delay > 0 else 60),
        ),
    )

    if args.no_animation:
        elapsed_ms = int((time.perf_counter() - started) * 1000)
        print("WONDERLAND OS")
        for stage in STAGES:
            print(f"PASS: {stage.name}")

        for name, status, _ok in full_results:
            print(f"{status.upper()}: {name}")

        write_startup_status(
            elapsed_ms=elapsed_ms,
            mode="no-animation",
            theme=args.theme,
            animation=args.animation,
            stages=as_status(checks),
        )

        print(f"WONDERLAND RUNTIME READY ({elapsed_ms} ms)")
        return 0 if args.visual_only or not has_required_failure else 1

    terminal.enter()

    try:
        for i in range(duration + 1):
            sys.stdout.write(scene.render_frame(i))
            sys.stdout.flush()
            time.sleep(fps_delay)

        elapsed_ms = int((time.perf_counter() - started) * 1000)

        write_startup_status(
            elapsed_ms=elapsed_ms,
            mode="fast" if args.fast else "normal",
            theme=args.theme,
            animation=args.animation,
            stages=as_status(checks),
        )

        sys.stdout.write(scene.render_ready())
        sys.stdout.flush()
        time.sleep(hold)
    finally:
        terminal.exit()

    return 0 if args.visual_only or not has_required_failure else 1


if __name__ == "__main__":
    raise SystemExit(main())
