from __future__ import annotations

import importlib
import inspect
import sys
from collections.abc import Sequence
from pathlib import Path

from wlbuilder.artifacts import collect_legacy_artifacts
from wlbuilder.context import create_context, ensure_output_dirs
from wlbuilder.pipeline import execute


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


def _legacy_build(repo_root: Path, argv: Sequence[str]) -> int:
    if str(repo_root) not in sys.path:
        sys.path.insert(0, str(repo_root))

    module = importlib.import_module("build.__main__")
    main = getattr(module, "main", None)

    if main is None:
        print("FAIL: build.__main__ does not expose main().", file=sys.stderr)
        return 1

    return _call_legacy_main(main, argv)


def run(repo_root: Path, profile: str) -> int:
    context = create_context(repo_root, profile)
    ensure_output_dirs(context)

    pipeline_status = execute(context)
    if pipeline_status != 0:
        return pipeline_status

    build_status = _legacy_build(repo_root, ["--profile", context.profile])
    if build_status != 0:
        return build_status

    collected = collect_legacy_artifacts(context)
    for artifact in collected:
        print(f"artifact: {artifact}")

    return 0
