from __future__ import annotations

import importlib
import inspect
import platform
import sys
from collections.abc import Sequence
from pathlib import Path


def _reject_direct_macos_execution() -> int:
    print("FAIL: direct wlbuilder execution on macOS is unsupported.", file=sys.stderr)
    print("Use:", file=sys.stderr)
    print("  bin/wl builder build --profile development", file=sys.stderr)
    return 1


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _call_legacy_main(main, argv: Sequence[str]) -> int:
    if len(inspect.signature(main).parameters) == 0:
        original_argv = sys.argv[:]
        try:
            sys.argv = ["python3 -m wlbuilder", *argv]
            result = main()
        finally:
            sys.argv = original_argv
    else:
        result = main(list(argv))

    return int(result or 0)


def _legacy_build(argv: Sequence[str]) -> int:
    repo_root = _repo_root()

    if str(repo_root) not in sys.path:
        sys.path.insert(0, str(repo_root))

    module = importlib.import_module("build.__main__")
    main = getattr(module, "main", None)

    if main is None:
        print("FAIL: build.__main__ does not expose main().", file=sys.stderr)
        return 1

    return _call_legacy_main(main, argv)


def _status() -> int:
    repo_root = _repo_root()
    runtime = Path(__file__).resolve()
    legacy = repo_root / "build" / "__main__.py"

    print("wlbuilder runtime: active")
    print(f"repo_root: {repo_root}")
    print(f"runtime: {runtime}")
    print("execution_path: builder/python/wlbuilder/runtime.py")
    print("legacy_bridge: build.__main__")
    print(f"legacy_bridge_file: {legacy}")
    print(f"legacy_bridge_exists: {str(legacy.exists()).lower()}")

    try:
        if str(repo_root) not in sys.path:
            sys.path.insert(0, str(repo_root))
        importlib.import_module("build.__main__")
        print("legacy_bridge_import: pass")
    except Exception as exc:
        print(f"legacy_bridge_import: fail: {exc}")

    try:
        from wlbuilder.context import create_context

        context = create_context(repo_root)
        print("config: pass")
        print(f"config_file: {context.config.path}")
        print(f"default_profile: {context.config.default_profile}")
        print(f"profile: {context.profile}")
        print(f"output_root: {context.output_root}")
        print(f"raw_output: {context.raw_output}")
        print(f"qcow2_output: {context.qcow2_output}")
        print(f"vmware_output: {context.vmware_output}")
        print(f"log_root: {context.log_root}")
        print(f"manifest_root: {context.manifest_root}")
        from wlbuilder.stages import default_pipeline

        print("pipeline:")
        for stage in default_pipeline():
            print(f"  - {stage.name}")
    except Exception as exc:
        print(f"config: fail: {exc}")

    return 0


def run(argv: Sequence[str] | None = None) -> int:
    if platform.system() == "Darwin":
        return _reject_direct_macos_execution()

    args = list(argv) if argv is not None else sys.argv[1:]

    from wlbuilder.cli import build_parser, parse

    if args in (["-h"], ["--help"]):
        build_parser().print_help()
        return 0

    if not args:
        args = ["build"]

    if args[0].startswith("-"):
        args = ["build", *args]

    parsed = parse(args)

    if parsed.command == "status":
        return _status()

    if parsed.command == "doctor":
        from wlbuilder.doctor import run_doctor

        return run_doctor(_repo_root())

    if parsed.command == "verify":
        from wlbuilder.verify import run_verify

        return run_verify(_repo_root())

    if parsed.command == "artifacts":
        from wlbuilder.context import create_context

        context = create_context(_repo_root())
        for artifact in sorted(context.output_root.rglob("*")):
            if artifact.is_file():
                print(artifact.relative_to(context.repo_root))
        return 0

    if parsed.command == "build":
        from wlbuilder.context import create_context, ensure_output_dirs
        from wlbuilder.pipeline import execute

        context = create_context(_repo_root(), parsed.profile)
        ensure_output_dirs(context)

        pipeline_status = execute(context)
        if pipeline_status != 0:
            return pipeline_status

        legacy_args = ["--profile", context.profile]
        build_status = _legacy_build(legacy_args)
        if build_status != 0:
            return build_status

        from wlbuilder.artifacts import collect_legacy_artifacts

        collected = collect_legacy_artifacts(context)
        for artifact in collected:
            print(f"artifact: {artifact}")

        return 0

    print("FAIL: no builder command provided.", file=sys.stderr)
    return 1
