#!/usr/bin/env python3
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import webbrowser
import socket
import os

root = Path(__file__).resolve().parent
os.chdir(root)

def free_port(start):
    for port in range(start, start + 50):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.bind(("127.0.0.1", port))
                return port
            except OSError:
                pass
    raise RuntimeError("No free Fluderation port found")

port = free_port(int(os.environ.get("WL_MATRIX_FLUDERATION_PORT", "8789")))
url = f"http://127.0.0.1:{port}"

print("PASS Matrix Fluderation")
print(f"url={url}")
print("mode=environmental-push-down-local-visual")
webbrowser.open(url)

ThreadingHTTPServer(("127.0.0.1", port), SimpleHTTPRequestHandler).serve_forever()
