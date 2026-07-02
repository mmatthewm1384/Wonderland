from __future__ import annotations

import importlib
import sys
from pathlib import Path

from wlbuilder.context import create_context, ensure_output_dirs
from wlbuilder.stages import default_pipeline


def run_verify(repo_root: Path | None = None) -> int:
    root = repo_root or Path.cwd()
    failed = False

    print("Builder Verify")
    print("--------------")

    def check(name: str, passed: bool, detail: str = "") -> None:
        nonlocal failed
        status = "PASS" if passed else "FAIL"
        print(f"{status} {name}: {detail}")
        failed = failed or not passed

    check("repo_root", (root / "builder").is_dir(), str(root))

    try:
        context = create_context(root)
        ensure_output_dirs(context)
        check("config", True, str(context.config.path))
        check("profile", bool(context.profile), context.profile)
        check("output_root", context.output_root.is_dir(), str(context.output_root))
    except Exception as exc:
        check("config", False, str(exc))
        context = None

    try:
        if str(root) not in sys.path:
            sys.path.insert(0, str(root))
        module = importlib.import_module("build.__main__")
        check("legacy_bridge", hasattr(module, "main"), "build.__main__")
    except Exception as exc:
        check("legacy_bridge", False, str(exc))

    try:
        pipeline = default_pipeline()
        check("pipeline", len(pipeline) > 0, ",".join(stage.name for stage in pipeline))
    except Exception as exc:
        check("pipeline", False, str(exc))

    return 1 if failed else 0
