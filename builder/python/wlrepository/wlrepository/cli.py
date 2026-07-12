from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from collections import Counter
from pathlib import Path

from .engine import RepositoryEngine


def repository_root() -> Path:
    configured = os.environ.get("WL_ROOT")
    if configured:
        return Path(configured).resolve()

    completed = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )

    if completed.returncode != 0:
        raise RuntimeError(
            completed.stderr.strip() or "not inside a Git repository"
        )

    return Path(completed.stdout.strip()).resolve()


def emit_result(result, *, json_output: bool) -> int:
    payload = result.as_dict()

    if json_output:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        for finding in result.findings:
            suffix = f" [{finding.path}]" if finding.path else ""
            print(
                f"{finding.level} {finding.code}: "
                f"{finding.message}{suffix}"
            )

        print(f"RESULT {payload['result']}")

    return 0 if result.passed else 1


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="wl repo",
        description="Wonderland Repository Policy Engine",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="emit machine-readable JSON",
    )

    subparsers = parser.add_subparsers(dest="command")

    subparsers.add_parser("status")
    subparsers.add_parser("generate")
    subparsers.add_parser("verify")
    subparsers.add_parser("doctor")
    subparsers.add_parser("tracked-ignored")

    explain = subparsers.add_parser("explain-ignore")
    explain.add_argument("path")

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        engine = RepositoryEngine(repository_root())

        if args.command in {None, "status"}:
            payload = engine.status()
            if args.json:
                print(json.dumps(payload, indent=2, sort_keys=True))
            else:
                print("Wonderland Repository Engine")
                print(f"version={payload['engine']['version']}")
                print(
                    "policy="
                    f"{payload['policy_path']}"
                )
                print(
                    "gitignore_synchronized="
                    f"{str(payload['synchronized']).lower()}"
                )
                print(
                    "tracked_ignored="
                    f"{payload['tracked_ignored']}"
                )
                print(
                    "RESULT "
                    f"{'PASS' if payload['synchronized'] else 'WARN'}"
                )
            return 0

        if args.command == "generate":
            engine.generate()
            print("PASS generated .gitignore from repository policy")
            print("RESULT PASS")
            return 0

        if args.command in {"verify", "doctor"}:
            return emit_result(
                engine.verify(),
                json_output=args.json,
            )

        if args.command == "tracked-ignored":
            paths = engine.tracked_ignored()

            if args.json:
                print(
                    json.dumps(
                        {
                            "count": len(paths),
                            "paths": paths,
                        },
                        indent=2,
                        sort_keys=True,
                    )
                )
                return 0

            counts = Counter(
                path.split("/", 1)[0] if "/" in path else "(root)"
                for path in paths
            )

            print(
                f"Tracked files matching ignore rules: {len(paths)}"
            )
            for prefix, count in sorted(
                counts.items(),
                key=lambda item: (-item[1], item[0]),
            ):
                print(f"{count:7d}  {prefix}")

            if paths:
                print()
                for path in paths:
                    print(path)

            return 0

        if args.command == "explain-ignore":
            ignored, detail = engine.check_ignore(args.path)
            if ignored:
                print(f"IGNORED {args.path}")
                print(detail)
                return 0

            print(f"TRACKABLE {args.path}")
            return 1

        parser.error(f"unknown command: {args.command}")
        return 2

    except (
        RuntimeError,
        OSError,
        subprocess.SubprocessError,
    ) as exc:
        print(f"FAIL {exc}", file=sys.stderr)
        print("RESULT FAIL", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
