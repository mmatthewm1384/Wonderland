#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

WL_HOME = Path(os.environ.get("WL_HOME", str(Path.home() / "Wonderland"))).expanduser()
MB_HOME = WL_HOME / "99-meta" / "mind-body-time-travel"
MB_PORTALS = MB_HOME / "portals"
MB_CURRENT = WL_HOME / "runtime" / "mind-body-time-travel" / "current"
HOST = "127.0.0.1"
PORT = int(os.environ.get("WL_MIND_BODY_PORT", "8790"))

def ensure():
    for p in [
        MB_PORTALS,
        WL_HOME / "04-knowledge" / "vault" / "Mind Body Time Travel" / "Portals",
        WL_HOME / "04-knowledge" / "vault" / "Mind Body Time Travel" / "Sessions",
        WL_HOME / "04-knowledge" / "next-testament" / "mind-body-time-travel",
    ]:
        p.mkdir(parents=True, exist_ok=True)

def esc(s):
    return str(s).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace('"',"&quot;")

def run(args):
    env = os.environ.copy()
    env["WL_HOME"] = str(WL_HOME)
    proc = subprocess.run(args, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env)
    return proc.returncode, proc.stdout

def portal_list():
    ensure()
    out = []
    for d in sorted(MB_PORTALS.iterdir()):
        f = d / "portal.json"
        if f.exists():
            try:
                data = json.loads(f.read_text())
            except Exception:
                data = {"id": d.name, "era": "unknown", "name": d.name}
            out.append(data)
    return out

def page(body):
    return f"""<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Mind + Body Time Travel</title>
<style>
:root {{
  color-scheme: dark;
  --bg: #07080d;
  --panel: rgba(18,24,37,.88);
  --line: #293346;
  --text: #eef4ff;
  --muted: #91a0b8;
  --past: #bba7ff;
  --present: #9fe6c8;
  --future: #9cc9ff;
}}
body {{
  margin:0;
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", system-ui, sans-serif;
  background:
    radial-gradient(circle at 20% 10%, rgba(187,167,255,.22), transparent 30%),
    radial-gradient(circle at 80% 10%, rgba(156,201,255,.18), transparent 30%),
    radial-gradient(circle at 50% 100%, rgba(159,230,200,.14), transparent 30%),
    var(--bg);
  color: var(--text);
}}
header {{ padding: 30px 34px; border-bottom:1px solid var(--line); }}
h1 {{ margin:0; font-size:38px; letter-spacing:-.04em; }}
main {{ max-width:1120px; margin:0 auto; padding:28px; }}
.panel {{ background:var(--panel); border:1px solid var(--line); border-radius:22px; padding:22px; margin-bottom:18px; box-shadow:0 24px 60px rgba(0,0,0,.25); }}
.grid {{ display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:16px; }}
.card {{ border:1px solid var(--line); border-radius:18px; padding:16px; background:rgba(255,255,255,.035); }}
.muted {{ color:var(--muted); }}
button,.button {{ display:inline-block; border:1px solid #88a8d8; border-radius:14px; padding:10px 14px; background:rgba(156,201,255,.12); color:var(--text); text-decoration:none; font:inherit; cursor:pointer; }}
input,textarea,select {{ width:100%; box-sizing:border-box; border:1px solid var(--line); background:#080c14; color:var(--text); border-radius:14px; padding:12px; margin:8px 0 14px; font:inherit; }}
pre {{ background:#080c14; border:1px solid var(--line); border-radius:14px; padding:14px; overflow:auto; }}
.badge {{ font-size:12px; text-transform:uppercase; letter-spacing:.08em; color:var(--muted); }}
.past {{ color:var(--past); }}
.present {{ color:var(--present); }}
.future {{ color:var(--future); }}
</style>
</head>
<body>
<header>
  <h1>Mind + Body Time Travel</h1>
  <p class="muted">Move through past memory, present state, and future embodiment.</p>
  <nav>
    <a class="button" href="/">Portals</a>
    <a class="button" href="/new">Create Portal</a>
    <a class="button" href="/session">New Session</a>
    <a class="button" href="/return">Return</a>
  </nav>
</header>
<main>{body}</main>
</body>
</html>""".encode()

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = urlparse(self.path).path
        qs = parse_qs(urlparse(self.path).query)
        if path == "/":
            self.home()
        elif path == "/new":
            self.new_form()
        elif path == "/visit":
            self.visit(qs.get("id", [""])[0])
        elif path == "/return":
            self.return_home()
        elif path == "/session":
            self.session()
        else:
            self.send_response(404); self.end_headers()

    def do_POST(self):
        if urlparse(self.path).path != "/new":
            self.send_response(404); self.end_headers(); return
        n = int(self.headers.get("content-length","0"))
        data = parse_qs(self.rfile.read(n).decode())
        era = data.get("era", ["present"])[0]
        name = data.get("name", [""])[0]
        note = data.get("note", [""])[0]
        code, out = run([str(WL_HOME / "bin" / "wl-mind-body"), "portal", era, name, note])
        self.send(page(f"<div class='panel'><h2>Created</h2><pre>{esc(out)}</pre><a class='button' href='/'>Back</a></div>"))

    def home(self):
        current = "Present mind. Present body."
        if MB_CURRENT.is_symlink():
            current = str(MB_CURRENT.resolve())
        cards = ""
        for p in portal_list():
            era = p.get("era","present")
            cards += f"""<div class="card">
<div class="badge {esc(era)}">{esc(era)}</div>
<h3>{esc(p.get("name",""))}</h3>
<p class="muted">{esc(p.get("created_at",""))}</p>
<p>{esc(p.get("note",""))}</p>
<a class="button" href="/visit?id={esc(p.get("id",""))}">Enter</a>
</div>"""
        if not cards:
            cards = "<p class='muted'>No portals yet. Create one.</p>"
        self.send(page(f"<div class='panel'><h2>Current Location</h2><p>{esc(current)}</p></div><div class='panel'><h2>Portals</h2><div class='grid'>{cards}</div></div>"))

    def new_form(self):
        self.send(page("""
<div class="panel">
<h2>Create Mind + Body Portal</h2>
<form method="post">
<label>Era</label>
<select name="era">
<option value="past">Past</option>
<option value="present" selected>Present</option>
<option value="future">Future</option>
</select>
<label>Name</label>
<input name="name" placeholder="Calm Strong Operator">
<label>Note</label>
<textarea name="note" rows="5" placeholder="What time-space are you creating?"></textarea>
<button>Create Portal</button>
</form>
</div>
"""))

    def visit(self, pid):
        code, out = run([str(WL_HOME / "bin" / "wl-mind-body"), "visit", pid])
        self.send(page(f"<div class='panel'><h2>Entered Time-Space</h2><pre>{esc(out)}</pre><a class='button' href='/'>Back</a></div>"))

    def return_home(self):
        code, out = run([str(WL_HOME / "bin" / "wl-mind-body"), "return"])
        self.send(page(f"<div class='panel'><h2>Returned</h2><pre>{esc(out)}</pre><a class='button' href='/'>Back</a></div>"))

    def session(self):
        code, out = run([str(WL_HOME / "bin" / "wl-mind-body"), "session"])
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
    print(f"Mind + Body Time Travel App: http://{HOST}:{PORT}")
    HTTPServer((HOST, PORT), Handler).serve_forever()

if __name__ == "__main__":
    main()
