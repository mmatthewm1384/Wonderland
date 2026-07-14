from __future__ import annotations

from wl.runtime.presentation.colors import CYAN, GREEN, MUTED, PURPLE, RESET
from wl.runtime.presentation.layout import center


def header(title: str, subtitle: str) -> list[str]:
    return [
        center(f"{CYAN}{title}{RESET}"),
        center(f"{GREEN}{subtitle}{RESET}"),
    ]


def footer(elapsed_ms: int) -> list[str]:
    return [
        center(f"{MUTED}Startup: {elapsed_ms} ms{RESET}"),
    ]


def status_line(name: str, status: str) -> str:
    if status == "pass":
        return center(f"{GREEN}✓ {name}{RESET}")
    if status == "fail":
        return center(f"{PURPLE}✗ {name}{RESET}")
    if status == "warn":
        return center(f"{MUTED}⚠ {name}{RESET}")
    return center(f"{MUTED}· {name}{RESET}")


def status_list(items: list[tuple[str, str]]) -> list[str]:
    return [status_line(name, status) for name, status in items]
