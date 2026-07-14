from __future__ import annotations

from wl.runtime.animation.legacy import LegacyPresetAnimation
from wl.runtime.animation.presets import names
from wl.runtime.animation.v3 import VortexAnimation


def available_animation_names() -> list[str]:
    return [*names(), "vortex"]


def get_animation(name: str, *, theme: str = "neon"):
    if name == "vortex":
        return VortexAnimation()

    available = names()

    if name not in available:
        raise ValueError(f"unknown animation: {name}")

    return LegacyPresetAnimation(name=name, theme=theme)
