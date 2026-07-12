from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class RegistryPaths:
    root: Path

    @property
    def domains(self) -> Path:
        return self.root / "architecture" / "domains.yaml"

    @property
    def capabilities(self) -> Path:
        return self.root / "capabilities" / "registry.yaml"

    @property
    def components(self) -> Path:
        return self.root / "architecture" / "components.yaml"

    @property
    def implementations(self) -> Path:
        return self.root / "architecture" / "implementations.yaml"

    @property
    def artifacts(self) -> Path:
        return self.root / "architecture" / "artifacts.yaml"

    @property
    def inventory(self) -> Path:
        return self.root / "vault/08-Operations/state/platform-inventory-latest.json"

    @property
    def ownership(self) -> Path:
        return self.root / "vault/08-Operations/state/platform-ownership-latest.json"


def _strip(value: str) -> str:
    return value.strip().strip('"').strip("'")


def parse_registry_list(path: Path, top_key: str) -> list[dict[str, Any]]:
    if not path.exists():
        return []

    entries: list[dict[str, Any]] = []
    current: dict[str, Any] | None = None
    in_section = False
    list_key: str | None = None

    for raw in path.read_text().splitlines():
        stripped = raw.strip()

        if not stripped or stripped.startswith("#"):
            continue

        if stripped == f"{top_key}:":
            in_section = True
            continue

        if not in_section:
            continue

        if stripped.startswith("- id:"):
            if current:
                entries.append(current)
            current = {"id": _strip(stripped.split(":", 1)[1]), "paths": [], "patterns": []}
            list_key = None
            continue

        if current is None:
            continue

        if stripped in {"paths:", "patterns:", "consumers:", "dependencies:", "prerequisites:"}:
            list_key = stripped[:-1]
            current.setdefault(list_key, [])
            continue

        if list_key and stripped.startswith("- "):
            current.setdefault(list_key, []).append(_strip(stripped[2:]))
            continue

        if ":" in stripped:
            key, value = stripped.split(":", 1)
            key = key.strip()
            value = _strip(value)

            if value == "[]":
                current[key] = []
            elif value.startswith("[") and value.endswith("]"):
                inner = value[1:-1].strip()
                current[key] = [] if not inner else [part.strip().strip('"').strip("'") for part in inner.split(",")]
            else:
                current[key] = value

            list_key = None

    if current:
        entries.append(current)

    return entries


def parse_domains(path: Path) -> dict[str, Any]:
    domains = parse_registry_list(path, "domains")

    ignore: list[str] = []
    artifact_patterns: dict[str, list[str]] = {}
    section: str | None = None
    current_group: str | None = None

    if path.exists():
        for raw in path.read_text().splitlines():
            stripped = raw.strip()
            if not stripped or stripped.startswith("#"):
                continue

            if stripped == "ignore:":
                section = "ignore"
                current_group = None
                continue

            if stripped == "artifact_patterns:":
                section = "artifact_patterns"
                current_group = None
                continue

            if section == "ignore" and stripped.startswith("- "):
                ignore.append(_strip(stripped[2:]))
                continue

            if section == "artifact_patterns":
                if stripped.endswith(":") and not stripped.startswith("- "):
                    current_group = stripped[:-1]
                    artifact_patterns[current_group] = []
                    continue
                if current_group and stripped.startswith("- "):
                    artifact_patterns[current_group].append(_strip(stripped[2:]))

    return {
        "domains": domains,
        "ignore": ignore,
        "artifact_patterns": artifact_patterns,
    }


def simple_match(path: str, pattern: str) -> bool:
    if pattern.endswith("*"):
        return path.startswith(pattern[:-1])
    if pattern.startswith("*"):
        return path.endswith(pattern[1:])
    return path == pattern or path.startswith(pattern + "/")


class RegistryEngine:
    def __init__(self, root: str | Path) -> None:
        self.root = Path(root).resolve()
        self.paths = RegistryPaths(self.root)

    def load_engines(self) -> list[dict[str, Any]]:
        return parse_registry_list(self.root / "architecture" / "engines.yaml", "engines")

    def engine_ids(self) -> set[str]:
        return {e.get("id", "") for e in self.load_engines() if e.get("id")}

    def engine(self, engine_id: str) -> dict[str, Any] | None:
        for engine in self.load_engines():
            if engine.get("id") == engine_id:
                return engine
        return None

    def engine_graph(self) -> dict[str, Any]:
        engines = self.load_engines()
        nodes = [
            {
                "id": e.get("id"),
                "name": e.get("name"),
                "status": e.get("status"),
                "owner": e.get("owner"),
            }
            for e in engines
        ]
        edges = []
        for e in engines:
            for dep in e.get("depends", []):
                edges.append({
                    "from": dep,
                    "to": e.get("id"),
                    "relationship": "dependency",
                })
        return {"nodes": nodes, "edges": edges}

    def verify_engines(self) -> list[str]:
        problems: list[str] = []
        path = self.root / "architecture" / "engines.yaml"

        if not path.exists():
            return [f"missing engine registry: {path}"]

        engines = self.load_engines()
        valid_statuses = {"active", "planned", "deprecated", "archived"}
        seen: set[str] = set()

        for engine in engines:
            engine_id = engine.get("id")
            if not engine_id:
                problems.append("engine missing id")
                continue

            if engine_id in seen:
                problems.append(f"duplicate engine id: {engine_id}")
            seen.add(engine_id)

            if not engine.get("name"):
                problems.append(f"engine missing name: {engine_id}")
            if not engine.get("owner"):
                problems.append(f"engine missing owner: {engine_id}")
            if not engine.get("purpose"):
                problems.append(f"engine missing purpose: {engine_id}")
            if engine.get("status") not in valid_statuses:
                problems.append(f"engine invalid status: {engine_id} -> {engine.get('status')}")

        engine_ids = seen
        for engine in engines:
            engine_id = engine.get("id")
            for dep in engine.get("depends", []):
                if dep not in engine_ids:
                    problems.append(f"engine dependency missing: {engine_id} -> {dep}")

        graph = {e.get("id"): list(e.get("depends", [])) for e in engines if e.get("id")}
        visiting: set[str] = set()
        visited: set[str] = set()

        def visit(node: str, chain: list[str]) -> None:
            if node in visiting:
                problems.append("engine dependency cycle: " + " -> ".join(chain + [node]))
                return
            if node in visited:
                return
            visiting.add(node)
            for dep in graph.get(node, []):
                visit(dep, chain + [node])
            visiting.remove(node)
            visited.add(node)

        for engine_id in graph:
            visit(engine_id, [])

        return problems

    def load_domains(self) -> dict[str, Any]:
        return parse_domains(self.paths.domains)

    def load_capabilities(self) -> list[dict[str, Any]]:
        return parse_registry_list(self.paths.capabilities, "capabilities")

    def load_components(self) -> list[dict[str, Any]]:
        return parse_registry_list(self.paths.components, "components")

    def load_implementations(self) -> list[dict[str, Any]]:
        return parse_registry_list(self.paths.implementations, "implementations")

    def load_artifacts(self) -> list[dict[str, Any]]:
        return parse_registry_list(self.paths.artifacts, "artifacts")

    def load_inventory(self) -> dict[str, Any]:
        if not self.paths.inventory.exists():
            return {}
        return json.loads(self.paths.inventory.read_text())

    def load_ownership(self) -> dict[str, Any]:
        if not self.paths.ownership.exists():
            return {}
        return json.loads(self.paths.ownership.read_text())

    def domain_ids(self) -> set[str]:
        return {d.get("id", "") for d in self.load_domains().get("domains", []) if d.get("id")}

    def capability_ids(self) -> set[str]:
        return {c.get("id", "") for c in self.load_capabilities() if c.get("id")}

    def component_ids(self) -> set[str]:
        return {c.get("id", "") for c in self.load_components() if c.get("id")}

    def classify_path(self, path: str) -> dict[str, Any]:
        domains = self.load_domains()

        for ignore in domains.get("ignore", []):
            if simple_match(path, ignore):
                return {
                    "path": path,
                    "domain": "ignored",
                    "owner": "Ignore Policy",
                    "capability": "ignore.policy",
                    "component": None,
                    "implementation": None,
                    "classification": "ignored",
                }

        for artifact in self.load_artifacts():
            for pattern in artifact.get("patterns", []):
                if simple_match(path, pattern):
                    return {
                        "path": path,
                        "domain": artifact.get("id"),
                        "owner": artifact.get("owner", "Artifact Policy"),
                        "capability": artifact.get("id"),
                        "component": None,
                        "implementation": None,
                        "classification": "artifact",
                        "disposition": artifact.get("disposition"),
                        "purge_allowed": artifact.get("purge_allowed", "false"),
                    }

        best_impl: dict[str, Any] | None = None
        best_impl_prefix = ""
        for impl in self.load_implementations():
            for prefix in impl.get("paths", []):
                if path == prefix or path.startswith(prefix + "/"):
                    if len(prefix) > len(best_impl_prefix):
                        best_impl = impl
                        best_impl_prefix = prefix

        components = {c.get("id"): c for c in self.load_components()}

        if best_impl:
            component = components.get(best_impl.get("component"), {})
            return {
                "path": path,
                "domain": component.get("domain"),
                "owner": component.get("owner"),
                "capability": component.get("capability"),
                "component": component.get("id"),
                "implementation": best_impl.get("id"),
                "classification": "implementation",
            }

        best_domain: dict[str, Any] | None = None
        best_domain_prefix = ""
        for domain in domains.get("domains", []):
            for prefix in domain.get("paths", []):
                if path == prefix or path.startswith(prefix + "/"):
                    if len(prefix) > len(best_domain_prefix):
                        best_domain = domain
                        best_domain_prefix = prefix

        if best_domain:
            return {
                "path": path,
                "domain": best_domain.get("id"),
                "owner": best_domain.get("owner"),
                "capability": best_domain.get("capability"),
                "component": None,
                "implementation": None,
                "classification": "domain",
            }

        return {
            "path": path,
            "domain": "unassigned",
            "owner": "UNASSIGNED",
            "capability": "review.required",
            "component": None,
            "implementation": None,
            "classification": "unassigned",
        }

    def owner(self, path: str) -> str:
        return str(self.classify_path(path).get("owner", "UNASSIGNED"))

    def capability(self, path: str) -> str:
        return str(self.classify_path(path).get("capability", "review.required"))

    def component(self, path: str) -> str | None:
        value = self.classify_path(path).get("component")
        return str(value) if value else None

    def domain(self, path: str) -> str:
        return str(self.classify_path(path).get("domain", "unassigned"))

    def verify(self) -> list[str]:
        problems: list[str] = []

        required = [
            ("engine registry", self.root / "architecture" / "engines.yaml"),
            ("domain registry", self.paths.domains),
            ("capability registry", self.paths.capabilities),
            ("component registry", self.paths.components),
            ("implementation registry", self.paths.implementations),
            ("artifact registry", self.paths.artifacts),
        ]

        for label, path in required:
            if not path.exists():
                problems.append(f"missing {label}: {path}")

        problems.extend(self.verify_engines())

        domain_ids = self.domain_ids()
        capability_ids = self.capability_ids()
        component_ids = self.component_ids()

        for component in self.load_components():
            if component.get("domain") not in domain_ids:
                problems.append(f"component references unknown domain: {component.get('id')} -> {component.get('domain')}")
            if component.get("capability") not in capability_ids:
                problems.append(f"component references unregistered capability: {component.get('id')} -> {component.get('capability')}")

        for implementation in self.load_implementations():
            if implementation.get("component") not in component_ids:
                problems.append(f"implementation references unknown component: {implementation.get('id')} -> {implementation.get('component')}")

        return problems
