from __future__ import annotations

from .providers import HTTPHealthProvider, TCPHealthProvider


class HealthEngine:
    def __init__(self):
        self.providers = [
            HTTPHealthProvider("wl-grafana", "http://127.0.0.1:3000/api/health"),
            HTTPHealthProvider("wl-prometheus", "http://127.0.0.1:9090/-/healthy"),
            HTTPHealthProvider("wl-loki", "http://127.0.0.1:3100/ready"),
            TCPHealthProvider("wl-nats", "127.0.0.1", 4222),
        ]

    def check(self, containers: list[dict]) -> dict:
        service_results = {}

        observed = {
            c.get("name"): c
            for c in containers
            if c.get("name")
        }

        for provider in self.providers:
            result = provider.check()
            service_results[result.name] = {
                "healthy": result.healthy,
                "detail": result.detail,
            }

        # Vaultwarden is commonly internal-only behind compose networking.
        # For now, v2 treats running container state as the readiness baseline.
        for name in ("wl-vaultwarden", "wl-vaultwarden-db", "wl-dns"):
            c = observed.get(name)
            service_results[name] = {
                "healthy": bool(c and c.get("running")),
                "detail": c.get("status") if c else "container missing",
            }

        running = [c for c in containers if c.get("running")]
        total = len(containers)

        return {
            "healthy": all(v["healthy"] for v in service_results.values()) if service_results else False,
            "containers_running": len(running),
            "containers_total": total,
            "services": service_results,
        }
