from __future__ import annotations

import atexit
import signal
import sys
from dataclasses import dataclass
from types import FrameType
from typing import TextIO


ALT_SCREEN_ENTER = "\x1b[?1049h"
ALT_SCREEN_EXIT = "\x1b[?1049l"
CURSOR_HIDE = "\x1b[?25l"
CURSOR_SHOW = "\x1b[?25h"
CLEAR_SCREEN = "\x1b[2J"
CURSOR_HOME = "\x1b[H"
RESET = "\x1b[0m"


@dataclass
class Screen:
    stream: TextIO = sys.stdout
    alternate: bool = True
    hide_cursor: bool = True
    enabled: bool = True

    _entered: bool = False
    _previous_sigint: object | None = None
    _previous_sigterm: object | None = None

    def __enter__(self) -> "Screen":
        self.enter()
        return self

    def __exit__(self, exc_type, exc, tb) -> None:
        self.leave()

    def enter(self) -> None:
        if self._entered:
            return

        if not self.enabled:
            self._entered = True
            return

        if self.alternate:
            self.write(ALT_SCREEN_ENTER)

        if self.hide_cursor:
            self.write(CURSOR_HIDE)

        self.clear()
        self.flush()

        self._entered = True
        atexit.register(self.leave)

        self._previous_sigint = signal.getsignal(signal.SIGINT)
        self._previous_sigterm = signal.getsignal(signal.SIGTERM)

        signal.signal(signal.SIGINT, self._handle_signal)
        signal.signal(signal.SIGTERM, self._handle_signal)

    def leave(self) -> None:
        if not self._entered:
            return

        try:
            if self.enabled:
                self.write(RESET)
                if self.hide_cursor:
                    self.write(CURSOR_SHOW)
                if self.alternate:
                    self.write(ALT_SCREEN_EXIT)
                self.flush()
        finally:
            self._entered = False
            self._restore_signals()

    def clear(self) -> None:
        self.write(CLEAR_SCREEN)
        self.write(CURSOR_HOME)

    def home(self) -> None:
        self.write(CURSOR_HOME)

    def render(self, text: str, clear: bool = True) -> None:
        if clear:
            self.clear()
        self.write(text)
        if not text.endswith("\n"):
            self.write("\n")
        self.flush()

    def write(self, text: str) -> None:
        self.stream.write(text)

    def flush(self) -> None:
        self.stream.flush()

    def _restore_signals(self) -> None:
        if self._previous_sigint is not None:
            signal.signal(signal.SIGINT, self._previous_sigint)
            self._previous_sigint = None

        if self._previous_sigterm is not None:
            signal.signal(signal.SIGTERM, self._previous_sigterm)
            self._previous_sigterm = None

    def _handle_signal(self, signum: int, frame: FrameType | None) -> None:
        self.leave()
        raise KeyboardInterrupt
