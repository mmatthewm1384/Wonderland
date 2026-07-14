from __future__ import annotations

RESET = "\033[0m"

COLORS = {
    "neon": [51, 45, 39, 81, 87, 123, 159, 201],
    "matrix": [46, 40, 82, 118, 154, 190],
    "minimal": [244, 250, 15],
}

PRESETS = {
    "dual-spinner": {
        "top": [
            "╭────────────────────╮",
            "╭──────────◇─────────╮",
            "╭────────◆───────────╮",
            "╭──────◇─────────────╮",
        ],
        "bottom": [
            "╰────────────────────╯",
            "╰─────────◇──────────╯",
            "╰───────────◆────────╯",
            "╰─────────────◇──────╯",
        ],
        "left": ["◜", "◟", "◞", "◝"],
        "right": ["◝", "◜", "◟", "◞"],
        "core": ["◐", "◓", "◑", "◒", "◎", "◉"],
        "pulse": ["✦", "✧", "◆", "◇", "✶", "✹", "◎", "◉"],
    },
    "hard-spin": {
        "top": [
            "╭━━━━━━━◇━━━━━━━━━━━━╮",
            "╭━━━━━━━━━━━◆━━━━━━━━╮",
            "╭━━━━━━━━━━━━━━◇━━━━━╮",
            "╭━━◆━━━━━━━━━━━━━━━━━╮",
        ],
        "bottom": [
            "╰━━━━━━━━━━━━◇━━━━━━━╯",
            "╰━━━━━━━━◆━━━━━━━━━━━╯",
            "╰━━━━━◇━━━━━━━━━━━━━━╯",
            "╰━━━━━━━━━━━━━━━━━◆━━╯",
        ],
        "left": ["◢", "◣", "◤", "◥"],
        "right": ["◥", "◢", "◣", "◤"],
        "core": ["◐", "◓", "◑", "◒", "◉", "◎"],
        "pulse": ["✹", "✶", "✸", "✷", "◆", "◇", "◎", "◉"],
    },
    "minimal": {
        "top": [
            "────────────────────",
            "──────────•─────────",
        ],
        "bottom": [
            "────────────────────",
            "─────────•──────────",
        ],
        "left": ["(", "{", "[", "<"],
        "right": [")", "}", "]", ">"],
        "core": ["-", "\\", "|", "/"],
        "pulse": ["·", "•"],
    },
}


def names() -> list[str]:
    return sorted(PRESETS)


def spinner_lines(i: int, *, preset: str = "dual-spinner", theme: str = "neon") -> list[str]:
    data = PRESETS[preset]
    palette = COLORS.get(theme, COLORS["neon"])
    c = palette[i % len(palette)]

    top = data["top"][i % len(data["top"])]
    bottom = data["bottom"][(len(data["bottom"]) - i) % len(data["bottom"])]
    left = data["left"][i % len(data["left"])]
    right = data["right"][(len(data["right"]) - i) % len(data["right"])]
    core = data["core"][i % len(data["core"])]
    pulse_a = data["pulse"][i % len(data["pulse"])]
    pulse_b = data["pulse"][(i + 4) % len(data["pulse"])]

    return [
        f"\033[38;5;{c}m                 {pulse_a}{RESET}",
        f"\033[38;5;{c}m          {top}{RESET}",
        f"\033[38;5;{c}m       {left}                        {right}{RESET}",
        f"\033[38;5;{c}m     ◥        {core}     WL     {pulse_b}        ◤{RESET}",
        f"\033[38;5;{c}m       {right}                        {left}{RESET}",
        f"\033[38;5;{c}m          {bottom}{RESET}",
        f"\033[38;5;{c}m                 {pulse_b}{RESET}",
    ]
