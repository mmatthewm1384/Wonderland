from __future__ import annotations

import argparse
import json
from pathlib import Path

from .engine import RegistryEngine


def cmd_doctor(engine: RegistryEngine, args: argparse.Namespace) -> int:
    problems = engine.verify()
    print("== Wonderland Registry Doctor ==")
    print(f"Root: {engine.root}")

    if problems:
        for problem in problems:
            print(f"FAIL {problem}")
        print("RESULT FAIL")
        return 1

    print("PASS domain registry")
    print("PASS capability registry")
    print("PASS component registry")
    print("PASS implementation registry")
    print("PASS artifact registry")
    print("RESULT PASS")
    return 0


def cmd_classify(engine: RegistryEngine, args: argparse.Namespace) -> int:
    result = engine.classify_path(args.path)
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(args.path)
        print(f"  domain: {result.get('domain')}")
        print(f"  owner: {result.get('owner')}")
        print(f"  capability: {result.get('capability')}")
        print(f"  component: {result.get('component')}")
        print(f"  implementation: {result.get('implementation')}")
        print(f"  classification: {result.get('classification')}")
        print("RESULT PASS" if result.get("owner") != "UNASSIGNED" else "RESULT WARN")
    return 0 if result.get("owner") != "UNASSIGNED" else 1


def cmd_list(engine: RegistryEngine, args: argparse.Namespace) -> int:
    mapping = {
        "domains": engine.load_domains().get("domains", []),
        "capabilities": engine.load_capabilities(),
        "components": engine.load_components(),
        "implementations": engine.load_implementations(),
        "artifacts": engine.load_artifacts(),
    }

    payload = mapping[args.kind]

    if args.json:
        print(json.dumps(payload, indent=2))
    else:
        print(f"Registry: {args.kind}")
        print()
        for item in payload:
            print(f"- {item.get('id')}")
        print("RESULT PASS")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="wl registry")
    parser.add_argument("--root", default=".", help="Wonderland repo root")

    sub = parser.add_subparsers(dest="command", required=True)

    p_doctor = sub.add_parser("doctor")
    p_doctor.set_defaults(func=cmd_doctor)

    p_classify = sub.add_parser("classify")
    p_classify.add_argument("path")
    p_classify.add_argument("--json", action="store_true")
    p_classify.set_defaults(func=cmd_classify)

    p_list = sub.add_parser("list")
    p_list.add_argument("kind", choices=["domains", "capabilities", "components", "implementations", "artifacts"])
    p_list.add_argument("--json", action="store_true")
    p_list.set_defaults(func=cmd_list)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    engine = RegistryEngine(Path(args.root).resolve())
    return args.func(engine, args)


if __name__ == "__main__":
    raise SystemExit(main())
