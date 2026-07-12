#!/usr/bin/env python3
from __future__ import annotations

import html
import json
import re
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path.cwd()
ACADEMY = ROOT / "academy"
REGISTRY = ACADEMY / "registry" / "chapters.json"
BUILD = ACADEMY / "build"

def fail(msg: str) -> int:
    print(f"FAIL {msg}", file=sys.stderr)
    return 1

def load_json(path: Path) -> dict:
    if not path.exists():
        raise FileNotFoundError(path)
    return json.loads(path.read_text())

def simple_markdown_to_html(markdown: str) -> str:
    out = []
    in_ul = False
    in_code = False
    code_lines = []

    def close_ul():
        nonlocal in_ul
        if in_ul:
            out.append("</ul>")
            in_ul = False

    for raw in markdown.splitlines():
        line = raw.rstrip()

        if line.startswith("```"):
            close_ul()
            if not in_code:
                in_code = True
                code_lines = []
            else:
                out.append("<pre><code>" + html.escape("\n".join(code_lines)) + "</code></pre>")
                in_code = False
            continue

        if in_code:
            code_lines.append(raw)
            continue

        if not line.strip():
            close_ul()
            continue

        if line.startswith("#"):
            close_ul()
            level = min(len(line) - len(line.lstrip("#")), 6)
            text = line[level:].strip()
            out.append(f"<h{level}>{html.escape(text)}</h{level}>")
            continue

        if line.startswith("- "):
            if not in_ul:
                out.append("<ul>")
                in_ul = True
            out.append(f"<li>{html.escape(line[2:].strip())}</li>")
            continue

        close_ul()
        escaped = html.escape(line)
        escaped = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", escaped)
        escaped = re.sub(r"`(.+?)`", r"<code>\1</code>", escaped)
        out.append(f"<p>{escaped}</p>")

    close_ul()
    return "\n".join(out)

def page(title: str, body: str) -> str:
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
<style>
:root {{
  color-scheme: dark;
  --bg: #05070A;
  --panel: #0B1020;
  --text: #EAF7FF;
  --muted: #9CB3C9;
  --cyan: #00E5FF;
  --purple: #7000FF;
}}
body {{
  margin: 0;
  background: var(--bg);
  color: var(--text);
  font: 16px/1.65 system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}}
main {{
  max-width: 900px;
  margin: 0 auto;
  padding: 48px 24px 96px;
}}
h1, h2, h3 {{
  line-height: 1.2;
}}
h1 {{
  color: var(--cyan);
  border-bottom: 1px solid rgba(0,229,255,.35);
  padding-bottom: .4em;
}}
a {{
  color: var(--cyan);
}}
pre {{
  background: var(--panel);
  border: 1px solid rgba(112,0,255,.4);
  border-radius: 12px;
  padding: 16px;
  overflow: auto;
}}
code {{
  color: var(--cyan);
}}
</style>
</head>
<body>
<main>
{body}
</main>
</body>
</html>
"""

def build_chapter(ch: dict) -> dict:
    chapter_dir = ACADEMY / ch["path"]
    manifest = load_json(chapter_dir / "manifest.json")
    chapter_md = chapter_dir / "chapter.md"

    if not chapter_md.exists():
        raise FileNotFoundError(chapter_md)

    cid = ch["id"]
    title = ch["title"]

    html_dir = BUILD / "html" / f"chapter-{cid}"
    html_dir.mkdir(parents=True, exist_ok=True)

    body = simple_markdown_to_html(chapter_md.read_text(errors="replace"))
    output = html_dir / "index.html"
    output.write_text(page(title, body))

    return {
        "id": cid,
        "title": title,
        "source": ch["path"],
        "manifest": f"{ch['path']}/manifest.json",
        "outputs": {
            "html": output.relative_to(ACADEMY).as_posix()
        },
        "counts": manifest.get("counts", {}),
    }

def clean() -> None:
    for name in ["html", "pdf", "epub", "search", "website"]:
        target = BUILD / name
        if target.exists():
            shutil.rmtree(target)
        target.mkdir(parents=True, exist_ok=True)

def build() -> int:
    if not REGISTRY.exists():
        return fail(f"missing registry: {REGISTRY}")

    registry = load_json(REGISTRY)
    clean()

    built = []
    for ch in registry.get("chapters", []):
        built.append(build_chapter(ch))
        print(f"PASS built html: chapter {ch['id']}")

    build_manifest = {
        "schema": "wonderland.academy.build.v1",
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "chapter_count": len(built),
        "targets": ["html"],
        "planned_targets": ["pdf", "epub", "search", "website"],
        "chapters": built,
    }

    (BUILD / "build-manifest.json").write_text(json.dumps(build_manifest, indent=2) + "\n")
    print(f"PASS wrote {BUILD / 'build-manifest.json'}")
    print("RESULT PASS")
    return 0

def validate() -> int:
    manifest_path = BUILD / "build-manifest.json"
    if not manifest_path.exists():
        return fail(f"missing build manifest: {manifest_path}")

    data = load_json(manifest_path)
    failures = 0

    if data.get("schema") == "wonderland.academy.build.v1":
        print("PASS build manifest schema")
    else:
        print("FAIL build manifest schema")
        failures += 1

    for ch in data.get("chapters", []):
        html_path = ACADEMY / ch["outputs"]["html"]
        if html_path.exists():
            print(f"PASS build output: {ch['outputs']['html']}")
        else:
            print(f"FAIL missing build output: {ch['outputs']['html']}")
            failures += 1

    print("RESULT PASS" if failures == 0 else "RESULT FAIL")
    return 0 if failures == 0 else 1

def summary() -> int:
    manifest_path = BUILD / "build-manifest.json"
    if not manifest_path.exists():
        return fail("no build manifest; run wl academy build first")

    data = load_json(manifest_path)
    print(f"Build: {data.get('generated_at')}")
    print(f"Chapters: {data.get('chapter_count')}")
    for ch in data.get("chapters", []):
        print(f"{ch['id']} | {ch['title']} | {ch['outputs']['html']}")
    return 0

def main() -> int:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "build"

    if cmd == "build":
        return build()
    if cmd == "validate":
        return validate()
    if cmd == "summary":
        return summary()

    print("Usage: build.py build|validate|summary", file=sys.stderr)
    return 64

if __name__ == "__main__":
    raise SystemExit(main())
