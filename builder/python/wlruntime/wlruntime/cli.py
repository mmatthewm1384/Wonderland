from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
from typing import Any

from .certification import RuntimeCertificationEngine
from .engine import RuntimeEngine
from .errors import RuntimeEngineError
from .registry import EngineRegistry
from .regression import run_regression_suite
from .release_gate import RuntimeReleaseGate
from .state import RuntimeStateStore


def print_json(value: Any) -> None:
    print(
        json.dumps(
            value,
            indent=2,
            sort_keys=True,
        )
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="wl-runtime-engine",
    )

    parser.add_argument(
        "--root",
        type=Path,
        default=Path(
            os.environ.get(
                "WL_ROOT",
                "/Users/wonderland/Wonderland",
            )
        ),
    )

    subcommands = parser.add_subparsers(
        dest="command",
        required=True,
    )

    for name in (
        "start",
        "stop",
        "restart",
        "sleep",
        "wake",
    ):
        command = subcommands.add_parser(name)
        command.add_argument(
            "--dry-run",
            action="store_true",
        )

    for name in (
        "registry",
        "graph",
        "plan",
        "verify",
        "health",
        "doctor",
        "recover",
        "status",
        "reset",
    ):
        subcommands.add_parser(name)

    certify = subcommands.add_parser(
        "certify",
        help="generate Runtime Engine certification evidence",
    )
    certify.add_argument(
        "--mode",
        choices=("standard", "full"),
        default="standard",
        help=(
            "standard is non-mutating; full exercises "
            "lifecycle and rollback"
        ),
    )
    certify.add_argument(
        "--require-clean",
        action="store_true",
        help="fail certification when the Git worktree is dirty",
    )

    subcommands.add_parser(
        "self-test",
        help="run isolated Runtime Engine regression tests",
    )

    release_gate = subcommands.add_parser(
        "release-gate",
        help="run the Runtime Engine RC1 release gate",
    )
    release_gate.add_argument(
        "--allow-dirty",
        action="store_true",
        help=(
            "allow a dirty worktree for development-only "
            "release-gate runs"
        ),
    )

    return parser




def main(argv: list[str] | None = None) -> int:
    arguments = build_parser().parse_args(argv)
    root = arguments.root.resolve()

    registry = EngineRegistry(
        root / "config/wonderland/runtime/engines.json"
    )
    state_store = RuntimeStateStore(
        root
        / "vault/08-Operations/state/"
        / "wl-runtime-engine.json"
    )
    engine = RuntimeEngine(
        root=root,
        registry=registry,
        state_store=state_store,
    )

    try:
        if arguments.command == "registry":
            result = {
                "result": "PASS",
                "path": str(registry.registry_path),
                "digest": registry.digest(),
                "engine_ids": list(registry.engine_ids()),
                "start_order": list(registry.start_order()),
                "stop_order": list(registry.stop_order()),
            }

        elif arguments.command == "graph":
            result = registry.graph()
            result["result"] = "PASS"

        elif arguments.command == "plan":
            result = {
                "result": "PASS",
                "start": engine.plan("start"),
                "stop": engine.plan("stop"),
            }

        elif arguments.command == "verify":
            result = engine.verify()

        elif arguments.command == "health":
            result = engine.health()

        elif arguments.command == "doctor":
            result = engine.doctor()

        elif arguments.command == "recover":
            result = engine.recover()

        elif arguments.command == "certify":
            certification = RuntimeCertificationEngine(
                root=root,
                registry=registry,
                state_store=state_store,
                engine=engine,
            ).certify(
                mode=arguments.mode,
                require_clean=arguments.require_clean,
            )

            result = {
                "result": certification.payload["result"],
                "mode": arguments.mode,
                "certificate": str(
                    certification.certificate_path
                ),
                "evidence": str(
                    certification.evidence_root
                ),
                "checks": certification.payload["checks"],
                "errors": certification.payload["errors"],
            }

        elif arguments.command == "self-test":
            result = run_regression_suite(
                verbosity=2
            )

        elif arguments.command == "release-gate":
            result = RuntimeReleaseGate(
                root=root,
                registry=registry,
                state_store=state_store,
                engine=engine,
            ).run(
                require_clean=not arguments.allow_dirty,
            )

        elif arguments.command == "reset":
            result = engine.reset()

        elif arguments.command == "status":
            result = state_store.read()
            result["result"] = "PASS"

        elif arguments.command == "start":
            result = engine.start(
                dry_run=arguments.dry_run
            )

        elif arguments.command == "stop":
            result = engine.stop(
                dry_run=arguments.dry_run
            )

        elif arguments.command == "restart":
            result = engine.restart(
                dry_run=arguments.dry_run
            )

        elif arguments.command == "sleep":
            result = engine.sleep(
                dry_run=arguments.dry_run
            )

        elif arguments.command == "wake":
            result = engine.wake(
                dry_run=arguments.dry_run
            )

        elif arguments.command == "restart":
            result = engine.restart(
                dry_run=arguments.dry_run
            )

        elif arguments.command == "sleep":
            result = engine.sleep(
                dry_run=arguments.dry_run
            )

        elif arguments.command == "wake":
            result = engine.wake(
                dry_run=arguments.dry_run
            )

        else:
            raise RuntimeError(
                f"unsupported command: {arguments.command}"
            )

        print_json(result)

        return (
            0
            if result.get("result", "PASS") == "PASS"
            else 1
        )

    except RuntimeEngineError as exc:
        print_json(
            {
                "result": "FAIL",
                "error": str(exc),
                "error_type": type(exc).__name__,
            }
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
