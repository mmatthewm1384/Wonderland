#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

echo "== Engine Architecture 1.0 — Patch A2 =="
echo "Registry Engine Support"
echo

test -f "$WL_ROOT/architecture/engines.yaml" || {
  echo "FAIL missing architecture/engines.yaml"
  echo "Run Patch A1 first."
  exit 1
}

mkdir -p \
  "$WL_ROOT/academy/generated" \
  "$WL_ROOT/vault/08-Operations/state" \
  "$WL_ROOT/vault/08-Operations/certifications"

python3 - <<'PY'
from pathlib import Path

p = Path("builder/python/wlregistry/wlregistry/engine.py")
s = p.read_text()

# Ensure inline YAML lists like depends: [] parse correctly.
old = '''        if ":" in stripped:
            key, value = stripped.split(":", 1)
            current[key.strip()] = _strip(value)
            list_key = None
'''
new = '''        if ":" in stripped:
            key, value = stripped.split(":", 1)
            key = key.strip()
            value = _strip(value)

            if value == "[]":
                current[key] = []
            elif value.startswith("[") and value.endswith("]"):
                inner = value[1:-1].strip()
                current[key] = [] if not inner else [
                    part.strip().strip('"').strip("'")
                    for part in inner.split(",")
                ]
            else:
                current[key] = value

            list_key = None
'''
if old in s:
    s = s.replace(old, new)

# Add Engine Registry API if missing.
if "def load_engines(self)" not in s:
    anchor = '''    def load_domains(self) -> dict[str, Any]:
        return parse_domains(self.paths.domains)
'''
    insert = '''    def load_engines(self) -> list[dict[str, Any]]:
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
            depends = e.get("depends", [])
            if isinstance(depends, str):
                depends = [depends] if depends else []
            for dep in depends:
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
            depends = engine.get("depends", [])
            if isinstance(depends, str):
                depends = [depends] if depends else []

            for dep in depends:
                if dep not in engine_ids:
                    problems.append(f"engine dependency missing: {engine_id} -> {dep}")

        graph: dict[str, list[str]] = {}
        for engine in engines:
            engine_id = engine.get("id")
            depends = engine.get("depends", [])
            if isinstance(depends, str):
                depends = [depends] if depends else []
            if engine_id:
                graph[engine_id] = list(depends)

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

'''
    if anchor not in s:
        raise SystemExit("Could not locate load_domains anchor in wlregistry engine.py")
    s = s.replace(anchor, insert + anchor)

# Make global verify include engine verification and registry file.
if '"engine registry"' not in s:
    s = s.replace(
'''        required = [
            ("domain registry", self.paths.domains),
''',
'''        required = [
            ("engine registry", self.root / "architecture" / "engines.yaml"),
            ("domain registry", self.paths.domains),
'''
    )

if "problems.extend(self.verify_engines())" not in s:
    s = s.replace(
'''        domain_ids = self.domain_ids()
''',
'''        problems.extend(self.verify_engines())

        domain_ids = self.domain_ids()
'''
    )

p.write_text(s)
PY

python3 - <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

root = Path.cwd()
sys.path.insert(0, str(root / "builder/python/wlregistry"))

from wlregistry.engine import RegistryEngine

registry = RegistryEngine(root)
problems = registry.verify_engines()
engines = registry.load_engines()
graph = registry.engine_graph()

status = "PASS" if not problems else "FAIL"
ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")

state = root / "vault/08-Operations/state/engine-registry-status.json"
cert = root / f"vault/08-Operations/certifications/engine-registry-certified-{ts}.json"
latest = root / "vault/08-Operations/state/engine-registry-certified-latest.json"
lesson = root / "academy/generated/engine-registry.md"

state_payload = {
    "project": "Engine Architecture 1.0",
    "phase": "1.1B",
    "status": status,
    "registry_engine": status,
    "engines_loaded": len(engines),
    "verification": status,
    "next_phase": "1.1C"
}

cert_payload = {
    "certification": "engine-registry",
    "status": status,
    "timestamp": datetime.now(timezone.utc).isoformat(),
    "engines_loaded": len(engines),
    "graph": graph,
    "problems": problems,
    "checks": [
        {"name": "engine registry exists", "status": "PASS"},
        {"name": "engine ids unique", "status": "PASS" if not any("duplicate engine id" in p for p in problems) else "FAIL"},
        {"name": "owners present", "status": "PASS" if not any("missing owner" in p for p in problems) else "FAIL"},
        {"name": "purposes present", "status": "PASS" if not any("missing purpose" in p for p in problems) else "FAIL"},
        {"name": "statuses valid", "status": "PASS" if not any("invalid status" in p for p in problems) else "FAIL"},
        {"name": "dependencies valid", "status": "PASS" if not any("dependency missing" in p for p in problems) else "FAIL"},
        {"name": "no cycles", "status": "PASS" if not any("cycle" in p for p in problems) else "FAIL"},
    ],
}

lesson.write_text("""# Engine Registry

## Purpose

The Engine Registry defines the highest-level architectural objects in Wonderland.

The platform hierarchy is:

```text
Platform
  ↓
Engine
  ↓
Domain
  ↓
Capability
  ↓
Component
  ↓
Implementation
  ↓
Files
Why Engines Exist

Engines prevent overlapping responsibilities.

Every major platform responsibility belongs to one engine. Capabilities, components, implementations, documentation, certification, and Academy lessons all trace back to that engine.

Registry Rule

The Registry Engine is the only subsystem that parses architecture/engines.yaml.

Other engines consume the Registry Engine API.

Explain It Test

The operator should be able to explain:

Why engines exist.
Which engine owns a capability.
Why dependency cycles are forbidden.
Why the Registry Engine is the source of truth.
How engines make Wonderland easier to understand and teach.
""")

state.write_text(json.dumps(state_payload, indent=2) + "\n")
cert.write_text(json.dumps(cert_payload, indent=2) + "\n")
latest.write_text(json.dumps(cert_payload, indent=2) + "\n")

print(f"State: {state}")
print(f"Certification: {cert}")
print(f"Latest: {latest}")
print(f"Lesson: {lesson}")

for problem in problems:
print(f"FAIL {problem}")

print(f"RESULT {status}")

if problems:
raise SystemExit(1)
PY

echo
echo "PASS Registry Engine supports engines"
echo "PASS Engine Registry verified"
echo "PASS Engine Registry certified"
echo "PASS Academy lesson generated"
echo
echo "RESULT PASS"
