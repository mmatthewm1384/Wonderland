from __future__ import annotations

import socket
import urllib.request
from dataclasses import dataclass


@dataclass
class HealthResult:
    name: str
    healthy: bool
    detail: str


class HTTPHealthProvider:
    def __init__(self, name: str, url: str, timeout: float = 2.0):
        self.name = name
        self.url = url
        self.timeout = timeout

    def check(self) -> HealthResult:
        try:
            with urllib.request.urlopen(self.url, timeout=self.timeout) as r:
                return HealthResult(self.name, 200 <= r.status < 500, f"http {r.status}")
        except Exception as e:
            return HealthResult(self.name, False, str(e))


class TCPHealthProvider:
    def __init__(self, name: str, host: str, port: int, timeout: float = 2.0):
        self.name = name
        self.host = host
        self.port = port
        self.timeout = timeout

    def check(self) -> HealthResult:
        try:
            with socket.create_connection((self.host, self.port), timeout=self.timeout):
                return HealthResult(self.name, True, "tcp ok")
        except Exception as e:
            return HealthResult(self.name, False, str(e))
