from __future__ import annotations

import argparse
import json
import subprocess
import sys
import urllib.request
from pathlib import Path


ROOT = Path.home() / "Wonderland"
API = "http://127.0.0.1:9105"


def run(cmd: list[str]) -> int:
    p = subprocess.run(cmd, cwd=ROOT)
    return p.returncode


def api_json(path: str) -> dict:
    with urllib.request.urlopen(f"{API}{path}", timeout=5) as r:
        return json.loads(r.read())


def cmd_status(_: argparse.Namespace) -> int:
    data = api_json("/api/v1/ready")
    print(json.dumps(data, indent=2, sort_keys=True))
    return 0 if data.get("ready") else 1


def cmd_state(_: argparse.Namespace) -> int:
    print(json.dumps(api_json("/api/v1/state"), indent=2, sort_keys=True))
    return 0


def cmd_config(_: argparse.Namespace) -> int:
    return run([str(ROOT / "bin/wl-config")])


def cmd_policy(_: argparse.Namespace) -> int:
    return run([str(ROOT / "bin/wl-policy")])


def cmd_schema(_: argparse.Namespace) -> int:
    return run([str(ROOT / "bin/wl-schema")])


def cmd_release(args: argparse.Namespace) -> int:
    return run([str(ROOT / "bin/wl-release"), args.action])


def cmd_backup(args: argparse.Namespace) -> int:
    return run([str(ROOT / "bin/wl-backup"), args.action])


def cmd_test(_: argparse.Namespace) -> int:
    return run([str(ROOT / "bin/wl-test")])


def cmd_dashboard(_: argparse.Namespace) -> int:
    return run([str(ROOT / "bin/wl-dashboard")])


def cmd_api(_: argparse.Namespace) -> int:
    return run([str(ROOT / "bin/wl-api-v2")])


def cmd_freeze(_: argparse.Namespace) -> int:
    return run([str(ROOT / "bin/wl-platform-freeze")])


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="wl", description="Wonderland unified CLI")
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("status")
    p.set_defaults(func=cmd_status)

    p = sub.add_parser("state")
    p.set_defaults(func=cmd_state)

    p = sub.add_parser("config")
    p.set_defaults(func=cmd_config)

    p = sub.add_parser("policy")
    p.set_defaults(func=cmd_policy)

    p = sub.add_parser("schema")
    p.set_defaults(func=cmd_schema)

    p = sub.add_parser("test")
    p.set_defaults(func=cmd_test)

    p = sub.add_parser("dashboard")
    p.set_defaults(func=cmd_dashboard)

    p = sub.add_parser("api")
    p.set_defaults(func=cmd_api)

    p = sub.add_parser("freeze")
    p.set_defaults(func=cmd_freeze)

    p = sub.add_parser("release")
    p.add_argument("action", choices=["certify", "manifest", "package", "verify", "build"])
    p.set_defaults(func=cmd_release)

    p = sub.add_parser("backup")
    p.add_argument("action", choices=["create", "verify", "preview", "restore-preview"])
    p.set_defaults(func=cmd_backup)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
