#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


REGISTRY_FILES = {
    "layout": "01-Platform/registry/repository-layout.json",
    "ownership": "01-Platform/registry/repository-ownership.json",
    "rules": "01-Platform/registry/repository-rules.json",
    "aliases": "01-Platform/registry/repository-aliases.json",
    "classification": "01-Platform/registry/repository-classification.json",
    "builders": "01-Platform/registry/builder-ownership.json",
}


@dataclass(frozen=True)
class RegistryResult:
    name: str
    path: Path
    exists: bool
    valid: bool
    error: str = ""


class RegistryService:
    def __init__(self, root: Path) -> None:
        self.root = root

    def registry_path(self, name: str) -> Path:
        if name not in REGISTRY_FILES:
            raise KeyError(f"unknown registry: {name}")
        return self.root / REGISTRY_FILES[name]

    def load(self, name: str) -> Any:
        path = self.registry_path(name)
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)

    def list(self) -> dict[str, str]:
        return REGISTRY_FILES.copy()

    def inspect(self) -> list[RegistryResult]:
        results: list[RegistryResult] = []

        for name, rel in REGISTRY_FILES.items():
            path = self.root / rel

            if not path.exists():
                results.append(RegistryResult(name, path, False, False, "missing"))
                continue

            try:
                json.loads(path.read_text())
                results.append(RegistryResult(name, path, True, True))
            except Exception as exc:
                results.append(RegistryResult(name, path, True, False, str(exc)))

        return results

    def verify(self) -> int:
        failures = 0

        for result in self.inspect():
            rel = result.path.relative_to(self.root)

            if result.exists and result.valid:
                print(f"PASS registry {result.name}: {rel}")
                continue

            failures += 1
            if not result.exists:
                print(f"FAIL registry {result.name} missing: {rel}")
            else:
                print(f"FAIL registry {result.name} invalid: {rel}: {result.error}")

        if failures:
            print(f"RESULT FAIL")
            return 1

        print("PASS unified registry service verified")
        print("RESULT PASS")
        return 0

    def get(self, name: str, key: str | None = None) -> Any:
        data = self.load(name)

        if not key:
            return data

        cur = data
        for part in key.split("."):
            if isinstance(cur, dict):
                cur = cur[part]
            elif isinstance(cur, list):
                cur = cur[int(part)]
            else:
                raise KeyError(key)

        return cur

    def explain_path(self, path_arg: str) -> dict[str, Any]:
        path = path_arg.strip("/")
        top = path.split("/", 1)[0]

        ownership = self.load("ownership")
        aliases = self.load("aliases").get("aliases", {})
        classifications = self.load("classification").get("classifications", {})

        result: dict[str, Any] = {
            "path": path,
            "top_level": top,
            "classification": classifications.get(top),
            "alias": aliases.get(top),
            "ownership": None,
            "status": "unknown",
        }

        if top in ownership:
            result["ownership"] = ownership[top]
            result["status"] = "constitutional"
            return result

        if top in aliases:
            target = aliases[top].get("target", "")
            area = target.split("/", 1)[0]
            result["ownership"] = ownership.get(area)
            result["status"] = "alias"
            return result

        if top in classifications:
            target = classifications[top].get("target", "")
            area = target.split("/", 1)[0]
            result["ownership"] = ownership.get(area)
            result["status"] = "classified"
            return result

        result["status"] = "unclassified"
        return result


def print_json(value: Any) -> None:
    print(json.dumps(value, indent=2, sort_keys=True))


def cmd_status(service: RegistryService) -> int:
    results = service.inspect()
    failures = [r for r in results if not (r.exists and r.valid)]

    print("Wonderland Unified Registry Service")
    print()
    print(f"Registries: {len(results)}")
    print(f"Healthy: {len(results) - len(failures)}")
    print(f"Failures: {len(failures)}")
    print("Result:", "PASS" if not failures else "FAIL")

    return 0 if not failures else 1


def cmd_list(service: RegistryService) -> int:
    for name, rel in service.list().items():
        print(f"{name}: {rel}")
    return 0


def cmd_show(service: RegistryService, name: str, key: str | None) -> int:
    try:
        print_json(service.get(name, key))
        return 0
    except Exception as exc:
        print(f"FAIL registry lookup failed: {exc}", file=sys.stderr)
        return 1


def cmd_explain(service: RegistryService, path: str) -> int:
    print_json(service.explain_path(path))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="wl-registry")
    parser.add_argument("command", nargs="?", default="status")
    parser.add_argument("name", nargs="?")
    parser.add_argument("key", nargs="?")
    parser.add_argument("--root", default=".")
    args = parser.parse_args()

    service = RegistryService(Path(args.root).resolve())

    if args.command == "status":
        return cmd_status(service)

    if args.command == "list":
        return cmd_list(service)

    if args.command in {"doctor", "verify"}:
        return service.verify()

    if args.command == "show":
        if not args.name:
            print("FAIL usage: wl registry show <registry> [key]", file=sys.stderr)
            return 1
        return cmd_show(service, args.name, args.key)

    if args.command == "explain":
        if not args.name:
            print("FAIL usage: wl registry explain <path>", file=sys.stderr)
            return 1
        return cmd_explain(service, args.name)

    print(f"FAIL unknown registry command: {args.command}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
