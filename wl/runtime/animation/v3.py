from __future__ import annotations

import math
from dataclasses import dataclass

from wl.runtime.animation.base import BaseAnimation
from wl.runtime.animation.frame import AnimationFrame
from wl.runtime.animation.gradients import truecolor_fg
from wl.runtime.presentation.colors import RESET
from wl.runtime.presentation.layout import center


OUTER_CHARS = ["·", "•", "●", "◆", "●", "•"]
INNER_CHARS = ["∙", "•", "●", "✦", "●", "•"]
CORE_CHARS = ["◌", "◎", "◉", "◎"]


@dataclass(frozen=True)
class VortexAnimation(BaseAnimation):
    name: str = "vortex"

    min_rows: int = 9
    max_rows: int = 15

    def render(self, frame: AnimationFrame, width: int) -> list[str]:
        t = frame.index * 0.155
        pulse = (math.sin(t * 1.35) + 1.0) / 2.0

        lines: list[str] = []

        safe_width = max(40, min(width, 120))
        columns = max(33, min(61, safe_width // 2))
        if columns % 2 == 0:
            columns += 1

        rows = max(self.min_rows, min(self.max_rows, columns // 4))
        if rows % 2 == 0:
            rows += 1

        half_rows = rows // 2
        half_cols = columns // 2

        for row in range(-half_rows, half_rows + 1):
            chars: list[str] = []

            for col in range(-half_cols, half_cols + 1):
                x = col / 2.25
                y = row * 1.18

                radius = math.sqrt(x * x + y * y)
                angle = math.atan2(y, x)

                core = radius < 0.75
                inner_ring = 1.65 < radius < 3.25
                middle_ring = 3.75 < radius < 5.45
                outer_ring = 5.95 < radius < 7.65

                clockwise = math.sin(angle * 5.0 + t * 1.65 + radius * 0.55)
                counter = math.cos(angle * -4.0 + t * 1.15 - radius * 0.35)
                shimmer = math.sin(radius * 2.7 - t * 2.1)

                if core:
                    chars.append(self._core(frame.index, pulse))
                elif inner_ring and clockwise > 0.28:
                    chars.append(self._glyph(INNER_CHARS, frame.index, radius, pulse, bright=True))
                elif middle_ring and counter > 0.48:
                    chars.append(self._glyph(OUTER_CHARS, frame.index, radius, pulse, bright=False))
                elif outer_ring and shimmer > 0.62:
                    chars.append(self._glyph(OUTER_CHARS, frame.index, radius, pulse, bright=False, dim=True))
                else:
                    chars.append(" ")

            visual_line = "".join(chars).rstrip()
            lines.append(center(visual_line, width))

        return lines

    def _core(self, index: int, pulse: float) -> str:
        char = CORE_CHARS[(index // 4) % len(CORE_CHARS)]
        r = 220 + int(35 * pulse)
        g = 120 + int(80 * pulse)
        b = 255
        return f"{truecolor_fg((r, g, b))}{char}{RESET}"

    def _glyph(
        self,
        glyphs: list[str],
        index: int,
        radius: float,
        pulse: float,
        *,
        bright: bool,
        dim: bool = False,
    ) -> str:
        glyph = glyphs[(int(radius * 2) + index // 2) % len(glyphs)]

        if bright:
            r = 180 + int(55 * pulse)
            g = 180 + int(55 * (1.0 - pulse))
            b = 255
        elif dim:
            r = 70 + int(45 * pulse)
            g = 140 + int(65 * pulse)
            b = 210
        else:
            r = 110 + int(80 * pulse)
            g = 170 + int(60 * (1.0 - pulse))
            b = 245

        return f"{truecolor_fg((r, g, b))}{glyph}{RESET}"
