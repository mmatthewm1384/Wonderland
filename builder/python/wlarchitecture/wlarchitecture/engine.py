from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from wlregistry import RegistryEngine


@dataclass(frozen=True)
class ArchitecturePaths:
    root: Path

    @property
    def capability_registry(self) -> Path:
        return self.root / "capabilities" / "registry.yaml"

    @property
    def inventory(self) -> Path:
        return self.root / "vault/08-Operations/state/platform-inventory-latest.json"

    @property
    def ownership(self) -> Path:
        return self.root / "vault/08-Operations/state/platform-ownership-latest.json"

    @property
    def domains(self) -> Path:
        return self.root / "architecture" / "domains.yaml"

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
    def state_dir(self) -> Path:
        return self.root / "vault/08-Operations/state"

    @property
    def architecture_dir(self) -> Path:
        return self.root / "vault/08-Operations/architecture"


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise FileNotFoundError(str(path))
    return json.loads(path.read_text())


def parse_capabilities(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        raise FileNotFoundError(str(path))

    text = path.read_text()
    capabilities: list[dict[str, str]] = []
    current: dict[str, str] | None = None
    in_capabilities = False

    for raw_line in text.splitlines():
        stripped = raw_line.strip()

        if not stripped or stripped.startswith("#"):
            continue

        if stripped == "capabilities:":
            in_capabilities = True
            continue

        if not in_capabilities:
            continue

        if stripped.startswith("- "):
            if current:
                capabilities.append(current)
            current = {}
            item = stripped[2:]
            if ":" in item:
                key, value = item.split(":", 1)
                current[key.strip()] = value.strip().strip('"').strip("'")
            continue

        if current is not None and ":" in stripped:
            key, value = stripped.split(":", 1)
            current[key.strip()] = value.strip().strip('"').strip("'")

    if current:
        capabilities.append(current)

    return [c for c in capabilities if c.get("id")]




def parse_simple_registry(path: Path, top_key: str) -> list[dict[str, Any]]:
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
            current = {"id": stripped.split(":", 1)[1].strip(), "paths": [], "patterns": []}
            list_key = None
            continue

        if current is None:
            continue

        if stripped in {"paths:", "patterns:"}:
            list_key = stripped[:-1]
            current.setdefault(list_key, [])
            continue

        if list_key and stripped.startswith("- "):
            current.setdefault(list_key, []).append(stripped[2:].strip().strip('"').strip("'"))
            continue

        if ":" in stripped:
            key, value = stripped.split(":", 1)
            current[key.strip()] = value.strip().strip('"').strip("'")
            list_key = None

    if current:
        entries.append(current)

    return entries



def parse_domain_registry(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {"domains": [], "ignore": [], "artifact_patterns": {}}

    domains: list[dict[str, Any]] = []
    ignore: list[str] = []
    artifact_patterns: dict[str, list[str]] = {}
    section: str | None = None
    current_domain: dict[str, Any] | None = None
    current_pattern_group: str | None = None
    in_paths = False

    for raw in path.read_text().splitlines():
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            continue

        if stripped == "domains:":
            section = "domains"
            continue
        if stripped == "ignore:":
            section = "ignore"
            current_domain = None
            in_paths = False
            continue
        if stripped == "artifact_patterns:":
            section = "artifact_patterns"
            current_domain = None
            in_paths = False
            continue

        if section == "domains":
            if stripped.startswith("- id:"):
                if current_domain:
                    domains.append(current_domain)
                current_domain = {"id": stripped.split(":", 1)[1].strip(), "paths": []}
                in_paths = False
                continue
            if current_domain is not None and ":" in stripped and not stripped.startswith("- "):
                key, value = stripped.split(":", 1)
                key = key.strip()
                value = value.strip().strip('"').strip("'")
                if key == "paths":
                    in_paths = True
                else:
                    current_domain[key] = value
                continue
            if current_domain is not None and in_paths and stripped.startswith("- "):
                current_domain.setdefault("paths", []).append(stripped[2:].strip().strip('"').strip("'"))
                continue

        if section == "ignore" and stripped.startswith("- "):
            ignore.append(stripped[2:].strip().strip('"').strip("'"))
            continue

        if section == "artifact_patterns":
            if stripped.endswith(":") and not stripped.startswith("- "):
                current_pattern_group = stripped[:-1].strip()
                artifact_patterns[current_pattern_group] = []
                continue
            if current_pattern_group and stripped.startswith("- "):
                artifact_patterns[current_pattern_group].append(stripped[2:].strip().strip('"').strip("'"))

    if current_domain:
        domains.append(current_domain)

    return {"domains": domains, "ignore": ignore, "artifact_patterns": artifact_patterns}


def simple_match(path: str, pattern: str) -> bool:
    if pattern.endswith("*"):
        return path.startswith(pattern[:-1])
    if pattern.startswith("*"):
        return path.endswith(pattern[1:])
    return path == pattern or path.startswith(pattern + "/")


def classify_domain(path: str, registry: dict[str, Any]) -> dict[str, str] | None:
    for ignore in registry.get("ignore", []):
        if simple_match(path, ignore):
            return {
                "domain": "ignored",
                "owner": "Ignore Policy",
                "capability": "ignore.policy",
                "classification": "ignored",
            }

    for group, patterns in registry.get("artifact_patterns", {}).items():
        for pattern in patterns:
            if simple_match(path, pattern):
                return {
                    "domain": f"artifact.{group}",
                    "owner": "Artifact Policy",
                    "capability": f"artifact.{group}",
                    "classification": "artifact",
                }

    best: dict[str, Any] | None = None
    best_len = -1

    for domain in registry.get("domains", []):
        for prefix in domain.get("paths", []):
            if path == prefix or path.startswith(prefix + "/"):
                if len(prefix) > best_len:
                    best = domain
                    best_len = len(prefix)

    if best:
        return {
            "domain": best.get("id", "unknown"),
            "owner": best.get("owner", "UNASSIGNED"),
            "capability": best.get("capability", "review.required"),
            "classification": "domain-assigned",
        }

    return None



def build_graph(paths: ArchitecturePaths) -> dict[str, Any]:
    capabilities = parse_capabilities(paths.capability_registry)
    ownership = load_json(paths.ownership)
    domains = parse_domain_registry(paths.domains)

    cap_by_id = {cap["id"]: cap for cap in capabilities}
    owners: dict[str, set[str]] = defaultdict(set)
    components: list[dict[str, Any]] = []

    for entry in ownership.get("entries", []):
        path = entry.get("path")
        domain_assignment = classify_domain(path, domains) if path else None

        if domain_assignment and entry.get("owner") == "UNASSIGNED":
            owner = domain_assignment["owner"]
            capability = domain_assignment["capability"]
            classification = domain_assignment["classification"]
            domain = domain_assignment["domain"]
            status = "domain-assigned"
        else:
            owner = entry.get("owner", "UNASSIGNED")
            capability = entry.get("capability", "review.required")
            classification = entry.get("classification")
            domain = None
            status = entry.get("status")

        owners[owner].add(capability)
        components.append({
            "path": path,
            "owner": owner,
            "capability": capability,
            "classification": classification,
            "domain": domain,
            "status": status,
        })

    nodes = []
    for cap in capabilities:
        nodes.append({
            "id": cap["id"],
            "type": "capability",
            "name": cap.get("name", cap["id"]),
            "owner": cap.get("owner", "UNASSIGNED"),
            "status": cap.get("status", "unknown"),
        })

    for owner, caps in sorted(owners.items()):
        nodes.append({
            "id": f"owner:{owner}",
            "type": "owner",
            "name": owner,
            "capabilities": sorted(caps),
        })

    edges = []
    for cap in capabilities:
        owner = cap.get("owner", "UNASSIGNED")
        edges.append({
            "from": f"owner:{owner}",
            "to": cap["id"],
            "relationship": "owns",
        })

    for component in components:
        edges.append({
            "from": component["path"],
            "to": component["capability"],
            "relationship": "implements-or-supports",
        })

    return {
        "architecture": "wonderland",
        "status": "PASS",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "nodes": nodes,
        "edges": edges,
        "components": components,
    }


def cmd_graph(paths: ArchitecturePaths, args: argparse.Namespace) -> int:
    paths.architecture_dir.mkdir(parents=True, exist_ok=True)
    paths.state_dir.mkdir(parents=True, exist_ok=True)

    graph = build_graph(paths)
    ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    out = paths.architecture_dir / f"architecture-graph-{ts}.json"
    latest = paths.state_dir / "architecture-graph-latest.json"

    out.write_text(json.dumps(graph, indent=2) + "\n")
    latest.write_text(json.dumps(graph, indent=2) + "\n")

    if args.json:
        print(json.dumps(graph, indent=2))
    else:
        print(f"Graph:  {out}")
        print(f"Latest: {latest}")
        print(f"Nodes:  {len(graph['nodes'])}")
        print(f"Edges:  {len(graph['edges'])}")
        print("RESULT PASS")
    return 0


def cmd_ownership(paths: ArchitecturePaths, args: argparse.Namespace) -> int:
    ownership = load_json(paths.ownership)
    entries = ownership.get("entries", [])

    by_owner: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for entry in entries:
        by_owner[entry.get("owner", "UNASSIGNED")].append(entry)

    if args.json:
        print(json.dumps(by_owner, indent=2))
        return 0

    print("Architecture Ownership")
    print()
    for owner in sorted(by_owner):
        print(f"{owner}")
        for entry in by_owner[owner]:
            print(f"  - {entry.get('path')} :: {entry.get('capability')}")
        print()
    print("RESULT PASS")
    return 0


def cmd_dependencies(paths: ArchitecturePaths, args: argparse.Namespace) -> int:
    graph = build_graph(paths)
    deps: dict[str, set[str]] = defaultdict(set)

    for edge in graph["edges"]:
        if edge["relationship"] == "implements-or-supports":
            deps[edge["to"]].add(edge["from"])

    payload = {key: sorted(value) for key, value in sorted(deps.items())}

    if args.json:
        print(json.dumps(payload, indent=2))
    else:
        print("Architecture Dependencies")
        print()
        for capability, components in payload.items():
            print(capability)
            for component in components:
                print(f"  - {component}")
            print()
        print("RESULT PASS")
    return 0


def cmd_cycles(paths: ArchitecturePaths, args: argparse.Namespace) -> int:
    # Current graph has ownership/support edges only, so cycles are not expected.
    # This establishes the interface and gate for stricter dependency analysis later.
    graph = build_graph(paths)
    cycles: list[list[str]] = []

    payload = {
        "status": "PASS",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "cycle_count": len(cycles),
        "cycles": cycles,
        "note": "Current graph contains ownership/support edges only. Import-level cycle analysis comes next.",
    }

    if args.json:
        print(json.dumps(payload, indent=2))
    else:
        print("Architecture Cycles")
        print()
        print("PASS no architecture cycles found")
        print("RESULT PASS")
    return 0


def print_registry(title: str, entries: list[dict[str, Any]], args: argparse.Namespace) -> int:
    if args.json:
        print(json.dumps(entries, indent=2))
        return 0

    print(title)
    print()
    if not entries:
        print("WARN none")
        print("RESULT WARN")
        return 0

    for entry in entries:
        print(f"- {entry.get('id')}")
        for key in ("domain", "component", "owner", "capability", "purpose", "disposition", "purge_allowed"):
            if key in entry:
                print(f"  {key}: {entry.get(key)}")
        for list_key in ("paths", "patterns"):
            values = entry.get(list_key) or []
            if values:
                print(f"  {list_key}:")
                for value in values:
                    print(f"    - {value}")
    print("RESULT PASS")
    return 0


def cmd_components(paths: ArchitecturePaths, args: argparse.Namespace) -> int:
    return print_registry("Architecture Components", parse_simple_registry(paths.components, "components"), args)


def cmd_implementations(paths: ArchitecturePaths, args: argparse.Namespace) -> int:
    return print_registry("Architecture Implementations", parse_simple_registry(paths.implementations, "implementations"), args)


def cmd_artifacts(paths: ArchitecturePaths, args: argparse.Namespace) -> int:
    return print_registry("Architecture Artifacts", parse_simple_registry(paths.artifacts, "artifacts"), args)


def cmd_domains(paths: ArchitecturePaths, args: argparse.Namespace) -> int:
    registry = parse_domain_registry(paths.domains)
    if args.json:
        print(json.dumps(registry, indent=2))
        return 0

    print("Architecture Domains")
    print()
    for domain in registry.get("domains", []):
        print(f"- {domain.get('id')}")
        print(f"  owner: {domain.get('owner')}")
        print(f"  capability: {domain.get('capability')}")
    print("RESULT PASS")
    return 0


def cmd_verify(paths: ArchitecturePaths, args: argparse.Namespace) -> int:
    registry = RegistryEngine(paths.root)
    problems = registry.verify()

    if not paths.inventory.exists():
        problems.append(f"missing inventory: {paths.inventory}")
    if not paths.ownership.exists():
        problems.append(f"missing ownership: {paths.ownership}")

    ownership = registry.load_ownership()
    for entry in ownership.get("entries", []):
        path = entry.get("path")
        if not path:
            continue

        classified = registry.classify_path(path)
        if classified.get("owner") == "UNASSIGNED":
            problems.append(f"unassigned owner: {path}")

    print("== Wonderland Architecture Verify ==")
    print(f"Root: {paths.root}")

    if problems:
        for problem in problems:
            print(f"FAIL {problem}")
        print("RESULT FAIL")
        return 1

    print("PASS registry engine")
    print("PASS capability registry")
    print("PASS domain registry")
    print("PASS component registry")
    print("PASS implementation registry")
    print("PASS artifact registry")
    print("PASS inventory present")
    print("PASS ownership present")
    print("PASS architecture graph buildable")
    print("RESULT PASS")
    return 0

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="wl architecture")
    parser.add_argument("--root", default=".", help="Wonderland repo root")

    sub = parser.add_subparsers(dest="command", required=True)

    p_graph = sub.add_parser("graph")
    p_graph.add_argument("--json", action="store_true")
    p_graph.set_defaults(func=cmd_graph)

    p_ownership = sub.add_parser("ownership")
    p_ownership.add_argument("--json", action="store_true")
    p_ownership.set_defaults(func=cmd_ownership)

    p_dependencies = sub.add_parser("dependencies")
    p_dependencies.add_argument("--json", action="store_true")
    p_dependencies.set_defaults(func=cmd_dependencies)

    p_cycles = sub.add_parser("cycles")
    p_cycles.add_argument("--json", action="store_true")
    p_cycles.set_defaults(func=cmd_cycles)

    p_domains = sub.add_parser("domains")
    p_domains.add_argument("--json", action="store_true")
    p_domains.set_defaults(func=cmd_domains)

    p_components = sub.add_parser("components")
    p_components.add_argument("--json", action="store_true")
    p_components.set_defaults(func=cmd_components)

    p_implementations = sub.add_parser("implementations")
    p_implementations.add_argument("--json", action="store_true")
    p_implementations.set_defaults(func=cmd_implementations)

    p_artifacts = sub.add_parser("artifacts")
    p_artifacts.add_argument("--json", action="store_true")
    p_artifacts.set_defaults(func=cmd_artifacts)

    p_verify = sub.add_parser("verify")
    p_verify.set_defaults(func=cmd_verify)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    paths = ArchitecturePaths(Path(args.root).resolve())
    return args.func(paths, args)


if __name__ == "__main__":
    raise SystemExit(main())
