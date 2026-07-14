#!/usr/bin/env bash
set -euo pipefail

# Wonderland Runtime Phase 1 — Runtime Core
# Creates the foundational runtime framework files:
#   wl/runtime/context.py
#   wl/runtime/screen.py
#   wl/runtime/layout.py
#   wl/runtime/renderer.py
#   wl/runtime/kernel.py
#
# Intent:
#   Establish a small, dependency-free terminal runtime core that future scenes,
#   widgets, dashboards, and boot flows can share.
#
# Usage:
#   bash scripts/runtime/phase1-runtime-core.sh
#   bash scripts/runtime/phase1-runtime-core.sh --force
#   bash scripts/runtime/phase1-runtime-core.sh --dry-run

SCRIPT_NAME="$(basename "$0")"
FORCE=0
DRY_RUN=0
ROOT="${WONDERLAND_ROOT:-$(pwd)}"
RUNTIME_DIR="$ROOT/wl/runtime"

usage() {
  cat <<USAGE
Usage: $SCRIPT_NAME [--force] [--dry-run] [--root PATH]

Options:
  --force      Overwrite existing Phase 1 files.
  --dry-run    Show what would be written without changing files.
  --root PATH  Repository root. Defaults to current directory or WONDERLAND_ROOT.
  -h, --help   Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --root)
      [[ $# -ge 2 ]] || { echo "ERROR: --root requires a path" >&2; exit 2; }
      ROOT="$2"
      RUNTIME_DIR="$ROOT/wl/runtime"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

write_file() {
  local path="$1"
  local content="$2"

  if [[ -e "$path" && "$FORCE" -ne 1 ]]; then
    echo "SKIP existing: ${path#$ROOT/}"
    return 0
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -e "$path" ]]; then
      echo "WOULD overwrite: ${path#$ROOT/}"
    else
      echo "WOULD create: ${path#$ROOT/}"
    fi
    return 0
  fi

  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
  echo "WRITE: ${path#$ROOT/}"
}

if [[ "$DRY_RUN" -ne 1 ]]; then
  mkdir -p "$RUNTIME_DIR"
fi

write_file "$RUNTIME_DIR/context.py" '"""Runtime context for Wonderland terminal applications.

The RuntimeContext is immutable operational metadata shared by the kernel,
scenes, widgets, renderers, and runtime services. It deliberately avoids direct
I/O so it remains easy to test.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Mapping


@dataclass(frozen=True)
class RuntimeContext:
    """Shared runtime configuration and paths."""

    root: Path
    state_dir: Path
    theme: str = "default"
    interactive: bool = True
    metadata: Mapping[str, str] = field(default_factory=dict)

    @classmethod
    def from_root(
        cls,
        root: Path | str,
        *,
        theme: str = "default",
        interactive: bool = True,
        state_dir: Path | str | None = None,
        metadata: Mapping[str, str] | None = None,
    ) -> "RuntimeContext":
        resolved_root = Path(root).expanduser().resolve()
        resolved_state = Path(state_dir).expanduser().resolve() if state_dir else resolved_root / "state" / "runtime"
        return cls(
            root=resolved_root,
            state_dir=resolved_state,
            theme=theme,
            interactive=interactive,
            metadata=dict(metadata or {}),
        )

    def ensure_state_dir(self) -> Path:
        """Create and return the runtime state directory."""

        self.state_dir.mkdir(parents=True, exist_ok=True)
        return self.state_dir
'

write_file "$RUNTIME_DIR/screen.py" '"""Terminal screen abstraction for Wonderland Runtime.

Screen owns terminal state: alternate buffer, cursor visibility, clear, draw,
flush, and restore. Rendering code should use this instead of writing ANSI
escape sequences directly.
"""

from __future__ import annotations

import shutil
import sys
from dataclasses import dataclass
from typing import TextIO


@dataclass(frozen=True)
class TerminalSize:
    columns: int
    rows: int


class Screen:
    """Small dependency-free terminal screen manager."""

    def __init__(self, stdout: TextIO | None = None, *, use_alt_screen: bool = True) -> None:
        self.stdout = stdout or sys.stdout
        self.use_alt_screen = use_alt_screen
        self._active = False
        self._cursor_hidden = False

    def size(self) -> TerminalSize:
        size = shutil.get_terminal_size(fallback=(100, 30))
        return TerminalSize(columns=max(20, size.columns), rows=max(10, size.lines))

    def start(self) -> None:
        if self._active:
            return
        if self.use_alt_screen:
            self.write("\x1b[?1049h")
        self.hide_cursor()
        self.clear()
        self._active = True

    def stop(self) -> None:
        if not self._active:
            return
        self.show_cursor()
        if self.use_alt_screen:
            self.write("\x1b[?1049l")
        self.flush()
        self._active = False

    def clear(self) -> None:
        self.write("\x1b[2J\x1b[H")

    def hide_cursor(self) -> None:
        if not self._cursor_hidden:
            self.write("\x1b[?25l")
            self._cursor_hidden = True

    def show_cursor(self) -> None:
        if self._cursor_hidden:
            self.write("\x1b[?25h")
            self._cursor_hidden = False

    def draw(self, frame: str) -> None:
        self.clear()
        self.write(frame)
        self.flush()

    def write(self, value: str) -> None:
        self.stdout.write(value)

    def flush(self) -> None:
        self.stdout.flush()

    def __enter__(self) -> "Screen":
        self.start()
        return self

    def __exit__(self, exc_type: object, exc: object, tb: object) -> None:
        self.stop()
'

write_file "$RUNTIME_DIR/layout.py" '"""Layout primitives for Wonderland Runtime.

Layout computes placement. It does not write to the terminal. Renderer consumes
layout results and produces frames.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True)
class Rect:
    x: int
    y: int
    width: int
    height: int

    def inset(self, *, x: int = 0, y: int = 0) -> "Rect":
        return Rect(
            x=self.x + x,
            y=self.y + y,
            width=max(0, self.width - (x * 2)),
            height=max(0, self.height - (y * 2)),
        )


@dataclass(frozen=True)
class PlacedLine:
    x: int
    y: int
    text: str


class LayoutEngine:
    """Predictable terminal layout helpers."""

    def viewport(self, columns: int, rows: int) -> Rect:
        return Rect(x=0, y=0, width=max(1, columns), height=max(1, rows))

    def centered_box(self, viewport: Rect, *, width: int, height: int) -> Rect:
        actual_width = min(width, viewport.width)
        actual_height = min(height, viewport.height)
        return Rect(
            x=viewport.x + max(0, (viewport.width - actual_width) // 2),
            y=viewport.y + max(0, (viewport.height - actual_height) // 2),
            width=actual_width,
            height=actual_height,
        )

    def center_lines(self, rect: Rect, lines: Iterable[str]) -> list[PlacedLine]:
        materialized = list(lines)
        start_y = rect.y + max(0, (rect.height - len(materialized)) // 2)
        placed: list[PlacedLine] = []
        for offset, line in enumerate(materialized):
            text = self.truncate(line, rect.width)
            x = rect.x + max(0, (rect.width - len(text)) // 2)
            y = start_y + offset
            if rect.y <= y < rect.y + rect.height:
                placed.append(PlacedLine(x=x, y=y, text=text))
        return placed

    def truncate(self, text: str, width: int) -> str:
        if width <= 0:
            return ""
        if len(text) <= width:
            return text
        if width == 1:
            return "…"
        return text[: width - 1] + "…"
'

write_file "$RUNTIME_DIR/renderer.py" '"""Frame renderer for Wonderland Runtime.

Renderer composes a full terminal frame from placed text. It does not own
terminal state; Screen is responsible for drawing and restoration.
"""

from __future__ import annotations

from collections.abc import Iterable

from .layout import PlacedLine
from .screen import TerminalSize


class Renderer:
    """Render placed terminal lines into a buffered frame."""

    def __init__(self, *, fill: str = " ") -> None:
        self.fill = fill[:1] or " "

    def compose(self, size: TerminalSize, lines: Iterable[PlacedLine]) -> str:
        canvas = [[self.fill for _ in range(size.columns)] for _ in range(size.rows)]

        for line in lines:
            if line.y < 0 or line.y >= size.rows:
                continue
            if line.x >= size.columns:
                continue

            x = max(0, line.x)
            text = line.text[-line.x:] if line.x < 0 else line.text
            for index, char in enumerate(text):
                column = x + index
                if column >= size.columns:
                    break
                canvas[line.y][column] = char

        return "\n".join("".join(row).rstrip() for row in canvas).rstrip() + "\n"
'

write_file "$RUNTIME_DIR/kernel.py" '"""Wonderland Runtime Kernel.

The kernel is the Phase 1 orchestration boundary. It wires context, screen,
layout, and rendering together so future scenes/widgets can reuse one stable
runtime core.
"""

from __future__ import annotations

import time
from collections.abc import Protocol
from dataclasses import dataclass

from .context import RuntimeContext
from .layout import LayoutEngine, PlacedLine
from .renderer import Renderer
from .screen import Screen


class Scene(Protocol):
    """Minimum scene protocol for Phase 1.

    Phase 2 can replace this protocol with a richer abstract base class without
    changing the kernel contract significantly.
    """

    def mount(self, kernel: "RuntimeKernel") -> None:
        ...

    def update(self, kernel: "RuntimeKernel") -> bool:
        """Return True while the scene should continue running."""
        ...

    def render(self, kernel: "RuntimeKernel") -> list[PlacedLine]:
        ...


@dataclass(frozen=True)
class RuntimeKernelConfig:
    frame_delay: float = 0.05
    max_frames: int | None = None


class RuntimeKernel:
    """Central runtime object for terminal applications."""

    def __init__(
        self,
        context: RuntimeContext,
        *,
        screen: Screen | None = None,
        renderer: Renderer | None = None,
        layout: LayoutEngine | None = None,
        config: RuntimeKernelConfig | None = None,
    ) -> None:
        self.context = context
        self.screen = screen or Screen(use_alt_screen=context.interactive)
        self.renderer = renderer or Renderer()
        self.layout = layout or LayoutEngine()
        self.config = config or RuntimeKernelConfig()
        self.frame = 0

    def run(self, scene: Scene) -> int:
        """Run a scene until completion or interruption."""

        self.context.ensure_state_dir()
        scene.mount(self)

        try:
            with self.screen:
                while True:
                    should_continue = scene.update(self)
                    size = self.screen.size()
                    frame = self.renderer.compose(size, scene.render(self))
                    self.screen.draw(frame)
                    self.frame += 1

                    if not should_continue:
                        return 0
                    if self.config.max_frames is not None and self.frame >= self.config.max_frames:
                        return 0
                    if self.config.frame_delay > 0:
                        time.sleep(self.config.frame_delay)
        except KeyboardInterrupt:
            return 130
'

# Ensure package marker exists without overwriting an existing one.
write_file "$RUNTIME_DIR/__init__.py" '"""Wonderland Runtime package."""'

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry run complete. No files changed."
  exit 0
fi

python3 -m compileall -q "$RUNTIME_DIR/context.py" "$RUNTIME_DIR/screen.py" "$RUNTIME_DIR/layout.py" "$RUNTIME_DIR/renderer.py" "$RUNTIME_DIR/kernel.py"
echo "PASS: Phase 1 Runtime Core files compile."
echo "Next: wire BootUI through RuntimeKernel, Screen, Renderer, and LayoutEngine."
