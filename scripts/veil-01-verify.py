#!/usr/bin/env python3
"""Static G1 verifier for the Veil-01 architecture package."""
from __future__ import annotations

import sys
from pathlib import Path

try:
    import yaml
except ImportError as exc:  # pragma: no cover
    raise SystemExit("PyYAML is required: python -m pip install pyyaml") from exc

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "vault/architecture/veil-01"
FILES = {
    "architecture": BASE / "veil-01.yaml",
    "systems": BASE / "system-model.yaml",
    "failures": BASE / "failure-modes.yaml",
    "capabilities": BASE / "capability-contract.yaml",
    "verification": BASE / "verification.yaml",
}


def load(name: str):
    path = FILES[name]
    with path.open("r", encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def main() -> int:
    errors: list[str] = []
    docs = {name: load(name) for name in FILES}

    # V01: canonical identity and system completeness.
    if docs["architecture"].get("id") != "veil-01":
        fail(errors, "V01: architecture id must be veil-01")
    systems = docs["systems"].get("systems", {})
    if not systems:
        fail(errors, "V01: system model contains no systems")
    for name, system in systems.items():
        for key in ("tier", "depends_on", "failure_behavior"):
            if key not in system:
                fail(errors, f"V01: system {name!r} missing {key}")

    # Dependency references must resolve.
    for name, system in systems.items():
        for dep in system.get("depends_on", []):
            if dep not in systems:
                fail(errors, f"V01: system {name!r} depends on unknown system {dep!r}")

    # V02: trust boundaries must reference known systems and be explicit.
    boundaries = docs["systems"].get("trust_boundaries", [])
    if not boundaries:
        fail(errors, "V02: no trust boundaries defined")
    for boundary in boundaries:
        members = boundary.get("members", [])
        if not members:
            fail(errors, f"V02: boundary {boundary.get('id')!r} has no members")
        for member in members:
            if member not in systems:
                fail(errors, f"V02: boundary {boundary.get('id')!r} references unknown system {member!r}")
        if not boundary.get("control"):
            fail(errors, f"V02: boundary {boundary.get('id')!r} has no control policy")

    # V03: physical actuation must be deny-by-default and capability gated.
    contract = docs["capabilities"].get("default_policy", {})
    if contract.get("deny_by_default") is not True:
        fail(errors, "V03: capability default_policy.deny_by_default must be true")
    actuation = docs["capabilities"].get("capabilities", [])
    control_caps = [c for c in actuation if c.get("effect") == "control"]
    for cap in control_caps:
        if not cap.get("requires"):
            fail(errors, f"V03: control capability {cap.get('id')!r} has no requirements")
    if not docs["systems"].get("capability_contract", {}).get("physical_actuation", {}).get("denies_by_default"):
        fail(errors, "V03: system-model physical actuation is not deny-by-default")

    # V04: modes and transitions must be defined by the canonical architecture.
    modes = {m["id"] for m in docs["architecture"].get("operating_modes", [])}
    if not modes:
        fail(errors, "V04: no operating modes defined")
    allowed = docs["architecture"].get("mode_transition", {}).get("allowed", [])
    for transition in allowed:
        try:
            source, target = transition.split("->", 1)
        except ValueError:
            fail(errors, f"V04: malformed transition {transition!r}")
            continue
        if source not in modes or target not in modes:
            fail(errors, f"V04: transition {transition!r} references unknown mode")

    # V05: each failure definition must provide detection, response, and recovery.
    failures = docs["failures"].get("failure_modes", [])
    if not failures:
        fail(errors, "V05: no failure modes defined")
    for failure in failures:
        for key in ("id", "triggers", "detection", "response", "recovery"):
            if key not in failure:
                fail(errors, f"V05: failure {failure.get('id')!r} missing {key}")
        if failure.get("detection") not in systems and failure.get("detection") != "observability":
            fail(errors, f"V05: failure {failure.get('id')!r} has unknown detection system")

    # V06: recovery must verify before reintegration.
    recovery = docs["systems"].get("recovery", {})
    if recovery.get("strategy") != "isolate_restore_verify_reintegrate":
        fail(errors, "V06: recovery strategy must be isolate_restore_verify_reintegrate")
    # Canonical schema uses the noun phrase `reintegration_requires`.
    required = set(recovery.get("reintegration_requires", []))
    for item in ("component_health", "configuration_integrity", "dependency_health", "functional_test", "evidence_record"):
        if item not in required:
            fail(errors, f"V06: recovery reintegration missing {item}")

    # V07: critical habitation path cannot depend on communications/WAN.
    sanctuary = systems.get("sanctuary", {})
    if "communications" in set(sanctuary.get("depends_on", [])):
        fail(errors, "V07: sanctuary directly depends on communications")
    if any(
        systems.get(x, {}).get("tier") == "critical"
        and "communications" in systems.get(x, {}).get("depends_on", [])
        for x in systems
    ):
        fail(errors, "V07: a critical system directly depends on communications")

    # V08: evidence must be an explicit interface and local observability must exist.
    interface_ids = {i.get("id") for i in docs["systems"].get("interfaces", [])}
    if "evidence" not in interface_ids:
        fail(errors, "V08: evidence interface is missing")
    obs = systems.get("observability", {})
    if "audit_events" not in obs.get("provides", []):
        fail(errors, "V08: observability does not provide audit_events")

    if errors:
        print("VEIL-01 G1: FAIL")
        for error in errors:
            print(f"- {error}")
        return 1

    print("VEIL-01 G1: PASS")
    print(f"systems={len(systems)} boundaries={len(boundaries)} failures={len(failures)} capabilities={len(actuation)} modes={len(modes)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
