from __future__ import annotations

from wl_controller.runtime.containers import ContainerRuntime


class RecoveryEngine:
    def __init__(self, runtime: ContainerRuntime):
        self.runtime = runtime

    def recover(self, containers: list[dict]) -> dict:
        critical = {
            "wl-vaultwarden",
            "wl-vaultwarden-db",
            "wl-loki",
            "wl-prometheus",
            "wl-grafana",
            "wl-nats",
            "wl-dns",
        }

        recovered = []
        failed = []

        observed = {c.get("name"): c for c in containers}

        for name in critical:
            c = observed.get(name)
            if c and not c.get("running"):
                if self.runtime.start(name):
                    recovered.append(name)
                else:
                    failed.append(name)

        return {
            "attempted": sorted(recovered + failed),
            "recovered": sorted(recovered),
            "failed": sorted(failed),
        }
