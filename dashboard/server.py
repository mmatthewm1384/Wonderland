#!/usr/bin/env python3
from __future__ import annotations

import json
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


API = "http://127.0.0.1:9105"


HTML = """<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Wonderland Dashboard</title>
  <style>
    body {
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, Inter, sans-serif;
      background: #05070A;
      color: #DFFBFF;
    }
    header {
      padding: 18px 24px;
      border-bottom: 1px solid #12343A;
      color: #00E5FF;
      font-size: 20px;
      font-weight: 700;
    }
    main {
      padding: 24px;
      display: grid;
      gap: 18px;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
      gap: 18px;
    }
    .card {
      background: #081015;
      border: 1px solid #12343A;
      border-radius: 14px;
      padding: 18px;
      box-shadow: 0 0 22px rgba(0, 229, 255, 0.08);
    }
    .title {
      color: #00E5FF;
      font-weight: 700;
      margin-bottom: 10px;
    }
    .ok { color: #00FF66; }
    .bad { color: #FF5577; }
    .warn { color: #FFD166; }
    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;
    }
    th, td {
      border-bottom: 1px solid #12343A;
      padding: 8px;
      text-align: left;
    }
    th {
      color: #00E5FF;
    }
    code {
      color: #00FF66;
    }
  </style>
</head>
<body>
  <header>Wonderland Platform Dashboard</header>
  <main>
    <section class="grid">
      <div class="card"><div class="title">Readiness</div><div id="ready">Loading...</div></div>
      <div class="card"><div class="title">Runtime</div><div id="runtime">Loading...</div></div>
      <div class="card"><div class="title">Services</div><div id="services-summary">Loading...</div></div>
      <div class="card"><div class="title">Drift</div><div id="drift">Loading...</div></div>
    </section>

    <section class="card">
      <div class="title">Resolved Services</div>
      <table>
        <thead>
          <tr>
            <th>Service</th>
            <th>Desired</th>
            <th>Running</th>
            <th>Healthy</th>
            <th>Ready</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody id="services"></tbody>
      </table>
    </section>

    <section class="card">
      <div class="title">Recent Events</div>
      <table>
        <thead>
          <tr>
            <th>Time</th>
            <th>Type</th>
          </tr>
        </thead>
        <tbody id="events"></tbody>
      </table>
    </section>
  </main>

<script>
function badge(value) {
  return value ? '<span class="ok">PASS</span>' : '<span class="bad">FAIL</span>';
}

async function load() {
  const state = await fetch('/proxy/state').then(r => r.json());
  const ready = await fetch('/proxy/ready').then(r => r.json());
  const drift = await fetch('/proxy/drift').then(r => r.json());

  document.getElementById('ready').innerHTML =
    badge(ready.ready) + '<br><code>' + state.certification.status + '</code>';

  document.getElementById('runtime').innerHTML =
    badge(state.runtime.running) + '<br><code>' + state.runtime.name + '</code>';

  const resolved = state.registry.resolved_services || {ready:0,total:0,services:[]};
  document.getElementById('services-summary').innerHTML =
    '<span class="ok">' + resolved.ready + '</span> / ' + resolved.total + ' ready';

  document.getElementById('drift').innerHTML =
    drift.drifted === 0
      ? '<span class="ok">0 drifted</span>'
      : '<span class="bad">' + drift.drifted + ' drifted</span>';

  document.getElementById('services').innerHTML = resolved.services.map(s => `
    <tr>
      <td><code>${s.name}</code></td>
      <td>${badge(s.desired)}</td>
      <td>${badge(s.running)}</td>
      <td>${badge(s.healthy)}</td>
      <td>${badge(s.ready)}</td>
      <td>${s.status || ''}</td>
    </tr>
  `).join('');

  const events = (state.events || []).slice(-20).reverse();
  document.getElementById('events').innerHTML = events.map(e => `
    <tr>
      <td>${new Date(e.ts * 1000).toLocaleString()}</td>
      <td><code>${e.type}</code></td>
    </tr>
  `).join('');
}

load();
setInterval(load, 5000);
</script>
</body>
</html>
"""


def api_json(path: str) -> bytes:
    with urllib.request.urlopen(f"{API}/api/v1/{path}", timeout=3) as r:
        return r.read()


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/" or self.path == "/index.html":
            body = HTML.encode()
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return

        routes = {
            "/proxy/state": "state",
            "/proxy/ready": "ready",
            "/proxy/drift": "drift",
            "/proxy/version": "version",
        }

        if self.path in routes:
            try:
                body = api_json(routes[self.path])
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
            except Exception as e:
                body = json.dumps({"error": str(e)}).encode()
                self.send_response(502)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
            return

        self.send_response(404)
        self.end_headers()

    def log_message(self, fmt, *args):
        return


def main() -> int:
    server = ThreadingHTTPServer(("127.0.0.1", 9110), Handler)
    print("Wonderland Dashboard listening on http://127.0.0.1:9110")
    server.serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
