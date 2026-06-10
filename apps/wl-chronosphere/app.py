#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

WL_HOME = Path(os.environ.get("WL_HOME", str(Path.home() / "Wonderland"))).expanduser()
CH_HOME = WL_HOME / "99-meta" / "chronosphere"
CH_PORTALS = CH_HOME / "portals"
CH_CURRENT = WL_HOME / "runtime" / "chronosphere" / "current"
HOST = "127.0.0.1"
PORT = int(os.environ.get("WL_CHRONOSPHERE_PORT", "8791"))

def ensure():
    for p in [
        CH_PORTALS,
        WL_HOME / "04-knowledge" / "vault" / "Chronosphere" / "Portals",
        WL_HOME / "04-knowledge" / "vault" / "Chronosphere" / "Times",
        WL_HOME / "04-knowledge" / "vault" / "Chronosphere" / "Places",
        WL_HOME / "04-knowledge" / "vault" / "Chronosphere" / "Identities",
        WL_HOME / "04-knowledge" / "vault" / "Chronosphere" / "Simulations",
        WL_HOME / "04-knowledge" / "vault" / "Chronosphere" / "Sessions",
        WL_HOME / "04-knowledge" / "next-testament" / "chronosphere",
    ]:
        p.mkdir(parents=True, exist_ok=True)

def esc(value):
    return str(value).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace('"',"&quot;")

def run(args):
    env = os.environ.copy()
    env["WL_HOME"] = str(WL_HOME)
    proc = subprocess.run(args, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env)
    return proc.returncode, proc.stdout

def portals():
    ensure()
    out = []
    for d in sorted(CH_PORTALS.iterdir()):
        f = d / "portal.json"
        if f.exists():
            try:
                data = json.loads(f.read_text())
            except Exception:
                data = {"id": d.name, "kind": "unknown", "name": d.name}
            out.append(data)
    return out

def page(body):
    return f"""<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Wonderland Chronosphere</title>
<style>
:root {{
  color-scheme: dark;
  --bg:#05070d;
  --panel:rgba(14,20,34,.9);
  --line:#28344d;
  --text:#eef4ff;
  --muted:#94a3b8;
  --time:#a78bfa;
  --place:#67e8f9;
  --identity:#86efac;
  --memory:#fbbf24;
  --world:#f0abfc;
}}
body {{
  margin:0;
  font-family:-apple-system,BlinkMacSystemFont,"SF Pro Display",system-ui,sans-serif;
  background:
    radial-gradient(circle at 15% 10%, rgba(167,139,250,.2), transparent 28%),
    radial-gradient(circle at 85% 20%, rgba(103,232,249,.16), transparent 30%),
    radial-gradient(circle at 50% 100%, rgba(240,171,252,.12), transparent 30%),
    var(--bg);
  color:var(--text);
}}
header {{ padding:32px 36px; border-bottom:1px solid var(--line); }}
h1 {{ margin:0; font-size:42px; letter-spacing:-.045em; }}
main {{ max-width:1180px; margin:0 auto; padding:28px; }}
.panel {{ background:var(--panel); border:1px solid var(--line); border-radius:24px; padding:22px; margin-bottom:18px; box-shadow:0 28px 70px rgba(0,0,0,.28); }}
.grid {{ display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:16px; }}
.card {{ border:1px solid var(--line); border-radius:18px; padding:16px; background:rgba(255,255,255,.035); }}
.muted {{ color:var(--muted); }}
.button,button {{ display:inline-block; border:1px solid #82a8ff; border-radius:14px; padding:10px 14px; background:rgba(130,168,255,.12); color:var(--text); text-decoration:none; font:inherit; cursor:pointer; margin:2px; }}
input,textarea,select {{ width:100%; box-sizing:border-box; border:1px solid var(--line); background:#070b14; color:var(--text); border-radius:14px; padding:12px; margin:8px 0 14px; font:inherit; }}
pre {{ background:#070b14; border:1px solid var(--line); border-radius:14px; padding:14px; overflow:auto; }}
.badge {{ font-size:12px; text-transform:uppercase; letter-spacing:.08em; color:var(--muted); }}
.time {{ color:var(--time); }}
.place {{ color:var(--place); }}
.identity {{ color:var(--identity); }}
.memory {{ color:var(--memory); }}
.world {{ color:var(--world); }}
</style>
</head>
<body>
<header>
  <h1>Wonderland Chronosphere</h1>
  <p class="muted">Visit times, places, identities, memories, and simulated worlds.</p>
  <nav>
    <a class="button" href="/">Portals</a>
    <a class="button" href="/new">Create Portal</a>
    <a class="button" href="/session">New Session</a>
    <a class="button" href="/where">Where Am I?</a>
    <a class="button" href="/return">Return</a>
  </nav>
</header>
<main>{body}</main>
</body>
</html>""".encode()

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        qs = parse_qs(parsed.query)
        if path == "/":
            self.home()
        elif path == "/new":
            self.new_form()
        elif path == "/visit":
            self.visit(qs.get("id", [""])[0])
        elif path == "/return":
            self.return_home()
        elif path == "/where":
            self.where()
        elif path == "/session":
            self.session()
        else:
            self.send_response(404); self.end_headers()

    def do_POST(self):
        if urlparse(self.path).path != "/new":
            self.send_response(404); self.end_headers(); return
        n = int(self.headers.get("content-length", "0"))
        data = parse_qs(self.rfile.read(n).decode())
        kind = data.get("kind", ["time"])[0]
        name = data.get("name", [""])[0]
        note = data.get("note", [""])[0]
        code, out = run([str(WL_HOME / "bin" / "wl-chronosphere"), "portal", kind, name, note])
        self.send(page(f"<div class='panel'><h2>Portal Created</h2><pre>{esc(out)}</pre><a class='button' href='/'>Back</a></div>"))

    def home(self):
        current = "Present time. Present location. Present identity."
        if CH_CURRENT.is_symlink():
            current = str(CH_CURRENT.resolve())
        cards = ""
        for p in portals():
            kind = p.get("kind", "time")
            cards += f"""<div class="card">
<div class="badge {esc(kind)}">{esc(kind)}</div>
<h3>{esc(p.get("name",""))}</h3>
<p class="muted">{esc(p.get("created_at",""))}</p>
<p>{esc(p.get("note",""))}</p>
<a class="button" href="/visit?id={esc(p.get("id",""))}">Enter</a>
</div>"""
        if not cards:
            cards = "<p class='muted'>No portals yet. Create one.</p>"
        self.send(page(f"<div class='panel'><h2>Current Coordinates</h2><p>{esc(current)}</p></div><div class='panel'><h2>Portals</h2><div class='grid'>{cards}</div></div>"))

    def new_form(self):
        self.send(page("""
<div class="panel">
<h2>Create Chronosphere Portal</h2>
<form method="post">
<label>Portal Type</label>
<select name="kind">
<option value="time">Time</option>
<option value="place">Place</option>
<option value="identity">Identity</option>
<option value="memory">Memory</option>
<option value="world">World Simulation</option>
</select>
<label>Name / Coordinate</label>
<input name="name" placeholder="Tokyo 2040, Portland 2024, Future Matthew, Paris 1889">
<label>Note</label>
<textarea name="note" rows="5" placeholder="What should this portal contain?"></textarea>
<button>Create Portal</button>
</form>
</div>
"""))

    def visit(self, pid):
        code, out = run([str(WL_HOME / "bin" / "wl-chronosphere"), "visit", pid])
        self.send(page(f"<div class='panel'><h2>Portal Entry</h2><pre>{esc(out)}</pre><a class='button' href='/'>Back</a></div>"))

    def return_home(self):
        code, out = run([str(WL_HOME / "bin" / "wl-chronosphere"), "return"])
        self.send(page(f"<div class='panel'><h2>Returned</h2><pre>{esc(out)}</pre><a class='button' href='/'>Back</a></div>"))

    def where(self):
        code, out = run([str(WL_HOME / "bin" / "wl-chronosphere"), "where"])
        self.send(page(f"<div class='panel'><h2>Current Coordinates</h2><pre>{esc(out)}</pre></div>"))

    def session(self):
        code, out = run([str(WL_HOME / "bin" / "wl-chronosphere"), "session"])
        self.send(page(f"<div class='panel'><h2>Session Created</h2><pre>{esc(out)}</pre><a class='button' href='/'>Back</a></div>"))

    def send(self, data):
        self.send_response(200)
        self.send_header("content-type", "text/html; charset=utf-8")
        self.send_header("content-length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, fmt, *args):
        return

def main():
    ensure()
    print(f"Chronosphere App: http://{HOST}:{PORT}")
    HTTPServer((HOST, PORT), Handler).serve_forever()

if __name__ == "__main__":
    main()
