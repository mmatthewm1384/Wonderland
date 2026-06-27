from __future__ import annotations

import json
import urllib.error
import urllib.request
from dataclasses import dataclass
from typing import Any


class WonderlandAPIError(RuntimeError):
    pass


@dataclass(frozen=True)
class WonderlandClient:
    base_url: str = "http://127.0.0.1:9105/api/v1"
    timeout: float = 5.0

    def _get(self, path: str) -> Any:
        url = self.base_url.rstrip("/") + "/" + path.lstrip("/")

        try:
            with urllib.request.urlopen(url, timeout=self.timeout) as response:
                body = response.read()
        except urllib.error.URLError as e:
            raise WonderlandAPIError(f"request failed: {url}: {e}") from e

        try:
            return json.loads(body)
        except json.JSONDecodeError as e:
            raise WonderlandAPIError(f"invalid JSON from {url}") from e

    def version(self) -> dict:
        return self._get("version")

    def ready(self) -> dict:
        return self._get("ready")

    def status(self) -> dict:
        return self._get("status")

    def state(self) -> dict:
        return self._get("state")

    def services(self) -> dict:
        return self._get("services")

    def events(self) -> dict:
        return self._get("events")

    def timeline(self) -> dict:
        return self._get("timeline")

    def drift(self) -> dict:
        return self._get("drift")

    def schema(self) -> dict:
        return self._get("schema")

    def config(self) -> dict:
        return self._get("config")

    def plugins(self) -> dict:
        return self._get("plugins")

    def openapi(self) -> dict:
        return self._get("openapi.json")

    def is_ready(self) -> bool:
        return bool(self.ready().get("ready"))

    def resolved_services(self) -> list[dict]:
        state = self.state()
        resolved = state.get("registry", {}).get("resolved_services", {})
        return list(resolved.get("services", []))
