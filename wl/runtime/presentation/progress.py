from __future__ import annotations

from wl.runtime.presentation.colors import DIM, GREEN, RESET


def progress_bar(progress: int, width: int = 28) -> str:
    progress = max(0, min(progress, 100))
    filled = int(width * progress / 100)
    return f"{GREEN}{'█' * filled}{DIM}{'░' * (width - filled)}{RESET}"
