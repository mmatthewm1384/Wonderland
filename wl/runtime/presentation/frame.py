from __future__ import annotations


def strip_ansi(text: str) -> str:
    out: list[str] = []
    i = 0

    while i < len(text):
        if text[i] == "\x1b":
            i += 1
            while i < len(text) and text[i] not in "ABCDEFGHJKSTfm":
                i += 1
            i += 1
            continue

        out.append(text[i])
        i += 1

    return "".join(out)


def center_lines(lines: list[str], *, width: int) -> list[str]:
    result: list[str] = []

    for line in lines:
        visible_len = len(strip_ansi(line))
        pad = max(0, (width - visible_len) // 2)
        result.append((" " * pad) + line)

    return result


def compose_screen(
    *,
    header: list[str],
    body: list[str],
    footer: list[str] | None = None,
    width: int,
    center_body: bool = True,
) -> str:
    rendered_body = center_lines(body, width=width) if center_body else body
    sections = header + [""] + rendered_body

    if footer:
        sections += [""] + footer

    return "\n".join(sections)
