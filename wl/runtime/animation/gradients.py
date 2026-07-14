from __future__ import annotations

from wl.runtime.animation.easing import clamp01


Color = tuple[int, int, int]


def lerp_channel(a: int, b: int, t: float) -> int:
    t = clamp01(t)
    return int(round(a + (b - a) * t))


def lerp_color(a: Color, b: Color, t: float) -> Color:
    return (
        lerp_channel(a[0], b[0], t),
        lerp_channel(a[1], b[1], t),
        lerp_channel(a[2], b[2], t),
    )


def truecolor_fg(color: Color) -> str:
    r, g, b = color
    return f"\x1b[38;2;{r};{g};{b}m"


def gradient(colors: list[Color], steps: int) -> list[Color]:
    if steps <= 0:
        return []
    if not colors:
        return []
    if len(colors) == 1:
        return [colors[0]] * steps

    result: list[Color] = []

    segments = len(colors) - 1
    for i in range(steps):
        t = i / max(steps - 1, 1)
        segment = min(int(t * segments), segments - 1)
        local_t = (t - (segment / segments)) * segments
        result.append(lerp_color(colors[segment], colors[segment + 1], local_t))

    return result
