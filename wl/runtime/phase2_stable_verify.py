from __future__ import annotations

from pathlib import Path

from wl.runtime.context import RuntimeContext
from wl.runtime.frame import Align, Box, Frame, Position, Rule, Style, Text
from wl.runtime.launcher import launch_rootless, run_scene
from wl.runtime.renderer import Renderer
from wl.runtime.scenes.boot import BootScene


class MemoryScreen:
    def __init__(self, height: int = 24, width: int = 80) -> None:
        self.height = height
        self.width = width
        self.cleared = False
        self.flushed = False
        self.drawn: list[tuple[int, int, str]] = []

    def size(self) -> tuple[int, int]:
        return self.height, self.width

    def clear(self) -> None:
        self.cleared = True
        self.drawn.clear()

    def draw(self, row: int, col: int, text: str) -> None:
        assert isinstance(row, int)
        assert isinstance(col, int)
        assert row >= 0
        assert col >= 0
        assert isinstance(text, str)
        self.drawn.append((row, col, text))

    def flush(self) -> None:
        self.flushed = True


def verify_frame_contract() -> None:
    frame = Frame.from_commands(
        Text("ok", row=1, col=1, style=Style(role="success")),
        Text("center", row=2, align=Align.CENTER),
        Box(row=3, col=2, width=12, height=4, title=" box "),
        Rule(row=8, col=2),
    )
    assert len(frame.commands) == 4
    assert Position(1, 2).row == 1


def verify_renderer_contract() -> None:
    screen = MemoryScreen()
    renderer = Renderer(screen)
    renderer.render(
        Frame.from_commands(
            Text("contract", row=2, col=3),
            Text("center", row=3, align=Align.CENTER),
            Box(row=4, col=2, width=10, height=3),
            Rule(row=9, col=2),
        )
    )
    assert screen.cleared
    assert screen.flushed
    assert any("contract" in item[2] for item in screen.drawn)


def verify_boot_launcher() -> None:
    screen = MemoryScreen()
    context = RuntimeContext(interactive=False, state_dir=Path(".runtime-test"), theme="default")
    result = run_scene(
        BootScene(max_ticks=1),
        context=context,
        screen=screen,
        alternate_screen=False,
        frame_interval=0,
    )
    assert result == 0
    assert screen.drawn


def verify_launch_rootless() -> None:
    assert launch_rootless(ticks=1, interactive=False) == 0


def main() -> int:
    verify_frame_contract()
    verify_renderer_contract()
    verify_boot_launcher()
    verify_launch_rootless()
    print("PASS runtime phase2 verify")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
