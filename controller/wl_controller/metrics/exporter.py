from __future__ import annotations


def _safe_label(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"').replace("\n", " ")


class MetricsExporter:
    def render(self, state: dict) -> str:
        containers = state.get("containers", [])
        health = state.get("health", {})
        events = state.get("events", [])
        controller = state.get("controller", {})
        resolved = state.get("registry", {}).get("resolved_services", {})
        services = resolved.get("services", [])
        scheduler = state.get("kernel", {}).get("scheduler", {}).get("tasks", [])

        lines = [
            "# HELP wonderland_runtime_running Runtime running state.",
            "# TYPE wonderland_runtime_running gauge",
            f"wonderland_runtime_running {1 if state.get('runtime', {}).get('running') else 0}",

            "# HELP wonderland_registry_valid Registry validity.",
            "# TYPE wonderland_registry_valid gauge",
            f"wonderland_registry_valid {1 if state.get('registry', {}).get('valid') else 0}",

            "# HELP wonderland_controller_cycle_seconds Last controller cycle duration.",
            "# TYPE wonderland_controller_cycle_seconds gauge",
            f"wonderland_controller_cycle_seconds {controller.get('cycle_duration_seconds', 0)}",

            "# HELP wonderland_containers_total Total observed containers.",
            "# TYPE wonderland_containers_total gauge",
            f"wonderland_containers_total {len(containers)}",

            "# HELP wonderland_containers_up Running observed containers.",
            "# TYPE wonderland_containers_up gauge",
            f"wonderland_containers_up {len([c for c in containers if c.get('running')])}",

            "# HELP wonderland_events_total Recent event count.",
            "# TYPE wonderland_events_total counter",
            f"wonderland_events_total {len(events)}",

            "# HELP wonderland_health_ready Platform health readiness.",
            "# TYPE wonderland_health_ready gauge",
            f"wonderland_health_ready {1 if health.get('healthy') else 0}",

            "# HELP wonderland_services_total Resolved service count.",
            "# TYPE wonderland_services_total gauge",
            f"wonderland_services_total {resolved.get('total', len(services))}",

            "# HELP wonderland_services_ready Ready service count.",
            "# TYPE wonderland_services_ready gauge",
            f"wonderland_services_ready {resolved.get('ready', 0)}",

            "# HELP wonderland_services_drifted Drifted service count.",
            "# TYPE wonderland_services_drifted gauge",
            f"wonderland_services_drifted {resolved.get('drifted', 0)}",
        ]

        lines.extend([
            "# HELP wonderland_service_desired Desired service state.",
            "# TYPE wonderland_service_desired gauge",
        ])
        for svc in services:
            name = _safe_label(str(svc.get("name", "")))
            lines.append(f'wonderland_service_desired{{service="{name}"}} {1 if svc.get("desired") else 0}')

        lines.extend([
            "# HELP wonderland_service_running Running service state.",
            "# TYPE wonderland_service_running gauge",
        ])
        for svc in services:
            name = _safe_label(str(svc.get("name", "")))
            lines.append(f'wonderland_service_running{{service="{name}"}} {1 if svc.get("running") else 0}')

        lines.extend([
            "# HELP wonderland_service_healthy Healthy service state.",
            "# TYPE wonderland_service_healthy gauge",
        ])
        for svc in services:
            name = _safe_label(str(svc.get("name", "")))
            lines.append(f'wonderland_service_healthy{{service="{name}"}} {1 if svc.get("healthy") else 0}')

        lines.extend([
            "# HELP wonderland_service_ready Ready service state.",
            "# TYPE wonderland_service_ready gauge",
        ])
        for svc in services:
            name = _safe_label(str(svc.get("name", "")))
            lines.append(f'wonderland_service_ready{{service="{name}"}} {1 if svc.get("ready") else 0}')

        lines.extend([
            "# HELP wonderland_scheduler_task_runs Scheduler task run count.",
            "# TYPE wonderland_scheduler_task_runs counter",
        ])
        for task in scheduler:
            name = _safe_label(str(task.get("name", "")))
            lines.append(f'wonderland_scheduler_task_runs{{task="{name}"}} {task.get("runs", 0)}')

        lines.extend([
            "# HELP wonderland_scheduler_task_failures Scheduler task failure count.",
            "# TYPE wonderland_scheduler_task_failures counter",
        ])
        for task in scheduler:
            name = _safe_label(str(task.get("name", "")))
            lines.append(f'wonderland_scheduler_task_failures{{task="{name}"}} {task.get("failures", 0)}')

        return "\n".join(lines) + "\n"
