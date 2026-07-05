from __future__ import annotations

import argparse
import json
from pathlib import Path

from wl.operator.backend.tmux import TmuxBackend
from wl.operator.kernel import OperatorKernel, SESSION
from wl.operator.registry import discover
from wl.operator.status import build_status, write_status
from wl.operator.workspace import workspace_names


def repo_root() -> Path:
    return Path.cwd()


def status_json(root: Path) -> dict:
    return build_status(root)


def cmd_start(args: argparse.Namespace) -> None:
    OperatorKernel(repo_root()).start(args.workspace)


def cmd_stop(args: argparse.Namespace) -> None:
    OperatorKernel(repo_root()).stop()


def cmd_restart(args: argparse.Namespace) -> None:
    OperatorKernel(repo_root()).restart(args.workspace)


def cmd_attach(args: argparse.Namespace) -> None:
    OperatorKernel(repo_root()).attach(args.workspace)


def cmd_status(args: argparse.Namespace) -> None:
    root = repo_root()

    if args.json:
        write_status(root)
        print(json.dumps(status_json(root), indent=2, sort_keys=True))
        return

    OperatorKernel(root).list_windows()


def cmd_reload(args: argparse.Namespace) -> None:
    OperatorKernel(repo_root()).reload()


def cmd_dashboard(args: argparse.Namespace) -> None:
    from wl.operator.dashboard import main

    raise SystemExit(main())


def cmd_verify(args: argparse.Namespace) -> None:
    root = repo_root()
    tmux = TmuxBackend(root=root, session=SESSION)
    tmux.require()
    print("PASS tmux found")

    from wl.operator.verify import main as verify_subsystem

    rc = verify_subsystem()
    if rc != 0:
        raise SystemExit(rc)

    if not tmux.exists():
        raise SystemExit(f"FAIL session missing: {SESSION}")
    print(f"PASS session exists: {SESSION}")

    if not tmux.conf.exists():
        raise SystemExit(f"FAIL theme missing: {tmux.conf}")
    print(f"PASS theme exists: {tmux.conf}")

    manifest = root / "state" / "operator" / "operator.json"
    if not manifest.exists():
        raise SystemExit(f"FAIL manifest missing: {manifest}")
    print(f"PASS manifest exists: {manifest}")


def cmd_doctor(args: argparse.Namespace) -> None:
    print("Wonderland Operator Doctor")
    print()
    cmd_verify(args)
    print()
    print("Status Contract:")
    print(json.dumps(status_json(repo_root()), indent=2, sort_keys=True))


def main() -> int:
    parser = argparse.ArgumentParser(prog="wl operator")
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("start")
    p.add_argument("--workspace", default="full", choices=workspace_names())
    p.set_defaults(func=cmd_start)

    p = sub.add_parser("stop")
    p.set_defaults(func=cmd_stop)

    p = sub.add_parser("restart")
    p.add_argument("--workspace", default="full", choices=workspace_names())
    p.set_defaults(func=cmd_restart)

    p = sub.add_parser("attach")
    p.add_argument("--workspace", default="full", choices=workspace_names())
    p.set_defaults(func=cmd_attach)

    p = sub.add_parser("status")
    p.add_argument("--json", action="store_true")
    p.set_defaults(func=cmd_status)

    p = sub.add_parser("reload")
    p.set_defaults(func=cmd_reload)

    p = sub.add_parser("dashboard")
    p.set_defaults(func=cmd_dashboard)

    p = sub.add_parser("verify")
    p.set_defaults(func=cmd_verify)

    p = sub.add_parser("doctor")
    p.set_defaults(func=cmd_doctor)

    args = parser.parse_args()
    args.func(args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
