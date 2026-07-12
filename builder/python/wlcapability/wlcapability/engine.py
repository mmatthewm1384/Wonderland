from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class Capability:
    id: str
    name: str
    owner: str
    purpose: str
    status: str
    raw: dict[str, Any]


class CapabilityRegistry:
    def __init__(self, root: Path) -> None:
        self.root = root
        self.path = root / "capabilities" / "registry.yaml"

    def load_text(self) -> str:
        if not self.path.exists():
            raise FileNotFoundError(f"missing capability registry: {self.path}")
        return self.path.read_text()

    def parse(self) -> list[Capability]:
        text = self.load_text()
        return parse_minimal_yaml_capabilities(text)

    def find(self, capability_id: str) -> Capability | None:
        for capability in self.parse():
            if capability.id == capability_id:
                return capability
        return None


def parse_minimal_yaml_capabilities(text: str) -> list[Capability]:
    """
    Minimal parser for the current registry.yaml shape.

    This intentionally avoids a PyYAML dependency for bootstrap reliability.
    It supports:
      capabilities:
        - id: ...
          name: ...
          owner: ...
          purpose: ...
          status: ...
    """
    capabilities: list[dict[str, str]] = []
    current: dict[str, str] | None = None
    in_capabilities = False

    for raw_line in text.splitlines():
        line = raw_line.rstrip()
        stripped = line.strip()

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

    result: list[Capability] = []
    for item in capabilities:
        cap_id = item.get("id", "").strip()
        if not cap_id:
            continue
        result.append(
            Capability(
                id=cap_id,
                name=item.get("name", cap_id),
                owner=item.get("owner", "UNASSIGNED"),
                purpose=item.get("purpose", ""),
                status=item.get("status", "unknown"),
                raw=dict(item),
            )
        )
    return result


def print_table(capabilities: list[Capability]) -> None:
    if not capabilities:
        print("WARN no capabilities registered")
        return

    print("Capability Registry")
    print()
    for cap in capabilities:
        print(f"- {cap.id}")
        print(f"  name: {cap.name}")
        print(f"  owner: {cap.owner}")
        print(f"  status: {cap.status}")


def cmd_list(registry: CapabilityRegistry, args: argparse.Namespace) -> int:
    caps = registry.parse()
    if args.json:
        print(json.dumps([cap.raw for cap in caps], indent=2))
    else:
        print_table(caps)
    return 0


def cmd_show(registry: CapabilityRegistry, args: argparse.Namespace) -> int:
    cap = registry.find(args.capability_id)
    if cap is None:
        print(f"FAIL capability not found: {args.capability_id}", file=sys.stderr)
        return 1

    if args.json:
        print(json.dumps(cap.raw, indent=2))
    else:
        print(cap.id)
        print(f"  name: {cap.name}")
        print(f"  owner: {cap.owner}")
        print(f"  status: {cap.status}")
        print(f"  purpose: {cap.purpose}")
    return 0


def cmd_owner(registry: CapabilityRegistry, args: argparse.Namespace) -> int:
    cap = registry.find(args.capability_id)
    if cap is None:
        print(f"FAIL capability not found: {args.capability_id}", file=sys.stderr)
        return 1
    print(cap.owner)
    return 0


def cmd_doctor(registry: CapabilityRegistry, args: argparse.Namespace) -> int:
    problems: list[str] = []

    try:
        caps = registry.parse()
    except Exception as exc:
        print(f"FAIL registry load: {exc}")
        return 1

    seen: set[str] = set()
    for cap in caps:
        if cap.id in seen:
            problems.append(f"duplicate capability id: {cap.id}")
        seen.add(cap.id)

        if not cap.owner or cap.owner == "UNASSIGNED":
            problems.append(f"missing owner: {cap.id}")
        if not cap.purpose:
            problems.append(f"missing purpose: {cap.id}")
        if not cap.status:
            problems.append(f"missing status: {cap.id}")

    print("== Wonderland Capability Doctor ==")
    print(f"Registry: {registry.path}")
    print(f"Capabilities: {len(caps)}")

    if problems:
        for problem in problems:
            print(f"FAIL {problem}")
        print("RESULT FAIL")
        return 1

    print("PASS registry parse")
    print("PASS unique capability ids")
    print("PASS owners assigned")
    print("PASS purposes assigned")
    print("RESULT PASS")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="wl capability")
    parser.add_argument("--root", default=".", help="Wonderland repo root")

    sub = parser.add_subparsers(dest="command", required=True)

    p_list = sub.add_parser("list")
    p_list.add_argument("--json", action="store_true")
    p_list.set_defaults(func=cmd_list)

    p_show = sub.add_parser("show")
    p_show.add_argument("capability_id")
    p_show.add_argument("--json", action="store_true")
    p_show.set_defaults(func=cmd_show)

    p_owner = sub.add_parser("owner")
    p_owner.add_argument("capability_id")
    p_owner.set_defaults(func=cmd_owner)

    p_doctor = sub.add_parser("doctor")
    p_doctor.set_defaults(func=cmd_doctor)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    registry = CapabilityRegistry(Path(args.root).resolve())
    return args.func(registry, args)


if __name__ == "__main__":
    raise SystemExit(main())
