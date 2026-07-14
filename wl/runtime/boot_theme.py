from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class BootTheme:
    name: str
    title: str
    subtitle: str
    ready_title: str
    control_plane: str

    border_h: str = "─"
    border_v: str = "│"
    corner_tl: str = "╭"
    corner_tr: str = "╮"
    corner_bl: str = "╰"
    corner_br: str = "╯"
    tee_l: str = "├"
    tee_r: str = "┤"

    pending: str = "○"
    active: str = "◌"
    ok: str = "●"
    warn: str = "▲"
    failed: str = "✖"
    skipped: str = "◇"

    progress_full: str = "█"
    progress_empty: str = "░"


THEMES = {
    "default": BootTheme(
        name="default",
        title="WONDERLAND OS",
        subtitle="Local-first • Private • Secure • Recoverable",
        ready_title="SYSTEM READY",
        control_plane="Wonderland Control Plane Online",
    ),
    "minimal": BootTheme(
        name="minimal",
        title="WONDERLAND",
        subtitle="Runtime Host",
        ready_title="READY",
        control_plane="Control Plane Online",
        border_h="-",
        border_v="|",
        corner_tl="+",
        corner_tr="+",
        corner_bl="+",
        corner_br="+",
        tee_l="+",
        tee_r="+",
        pending=".",
        active="*",
        ok="+",
        warn="!",
        failed="x",
        skipped="-",
        progress_full="#",
        progress_empty=".",
    ),
    "matrix": BootTheme(
        name="matrix",
        title="THE MATRIX",
        subtitle="Wonderland Runtime Visualization Layer",
        ready_title="MATRIX ONLINE",
        control_plane="Visualization Control Plane Online",
        pending="·",
        active="◌",
        ok="●",
        warn="△",
        failed="✕",
        skipped="◇",
    ),
}


def get_boot_theme(name: str | None) -> BootTheme:
    if not name:
        return THEMES["default"]
    return THEMES.get(name, THEMES["default"])
